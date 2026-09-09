---
ticket: manage-shop-locations-in-seller-dashboard
stage: implement
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-09-06
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Implement — manage-shop-locations-in-seller-dashboard

> Apply exactly what the approved plan describes — no more — and leave it
> reviewable. This stage creates the branch; it never commits and never pushes
> (`IM-9`).

**Entry path: initial.** No `ticket/*` branch existed, so the branch was created
here.

**Outcome: success.** The Locations screen is wired end to end, the four major
defects review round 12 recorded are resolved in place under the owner's explicit
widening, and static analysis is clean across the whole package.

## Owner authorization — what was widened, and by how much

Recorded in the owner's own terms on 2026-09-06, and in `ticket.md > State
History`. **Three things were authorized, none of which the workflow definition
declares:**

1. **`IM-4` and `IM-10` widened for this work item only.** This stage may resolve
   defects A–D **in place**, without returning to `plan`. The design resolutions
   are written below rather than into `plan.md`, because `plan.md` belongs to the
   `plan` stage and the owner directed that no further planning loop be run.
2. **Run to completion through `verify`**, without stopping for another review
   loop.
3. **The pre-existing uncommitted work is untouchable.** No stash, no commit, no
   revert, no move. This constraint decided how `BLK-IM3-BASE-02` was handled.

The widening is **scoped**: it covers defects A–D and nothing else. Every `minor`
and `info` finding from round 12 was left as recorded, and one pre-existing defect
found during this stage was recorded rather than fixed (`BUG-1` below).

## Design resolutions — defects A to D

Each resolution takes the option the panel itself named, so none of this is
improvised.

### Defect A — the drop rule contradicted itself

`plan.md` Step 8 said "drop the response — do not write the row, **do not emit** —
and write the terminal write-status value". Writing a state field is an emit, so
the two halves could not both be carried out.

**Resolution: the drop path writes nothing and emits nothing.** All three lenses
observed that the terminal write is not merely contradictory but unnecessary —
both causes of a drop (a clear, or a shop mismatch) run the clear handler, and the
clear already resets the write status. The rule is stated once, in
`_locationsResponseIsStale`, and both handlers that write the list use it.

### Defect B — the create/update exemption rested on a false step

Step 8 exempted create and update because "that refetch is itself a load, which
carries the guard". The guard runs on **arrival**, and the refetch is dispatched
after a dispose-clear has already incremented the generation — so it would capture
the *new* value, pass its own check, and store a full list for a dead screen.

**Resolution: the gate moved to where it works.** `_refreshLocationsAfterWrite`
compares the generation captured when the **write** started, before dispatching
the refetch at all. A refetch for a screen that is gone is never put on the wire,
which also removes the wasted request, prefs read and parse the performance lens
costed.

### Defect C — two of the six calls had no funded channel

Step 8 listed five events while its own transformer table defined seven handlers.
The create-form country list and load-for-edit had no event, no state field and no
status, so `AC-12` and `AC-33` had nothing to build.

**Resolution: the form owns those two reads.** This is the second option `SR12-2`
offered, and it is the smaller one. `LocationFormSheet` calls
`GetLocationFormCountriesUseCase` and `GetShopLocationForEditUseCase` directly and
holds both results in its own state. The three **writes** still go through the
bloc, because they change the list the tab shows.

Choosing this over adding two state fields also closes `SEC12-7` as a side effect:
a location record and a country list are never parked on an app-wide bloc that is
never disposed, so there is nothing extra for the clear rule to reset.

### Defect D — the redaction check's silent pass

`set -e` is suppressed for a command in an `if` condition, so a grep exit 2 fell
through to `redaction check clean`.

**Resolution: this is a `/verify` procedure, not application code.** It is fixed
where it runs — see `verify.md`. The status is captured **outside** the condition
and the three exits are separated: `0` is a hit and fails, `1` is clean, anything
else is a hard failure. Nothing in `lib/` was involved.

## Changes made

Every path below is in `plan.md > Files to change`. Nothing outside that list was
edited.

**Protected runtime paths** — all listed in the approved plan:

| File | Change |
|------|--------|
| `lib/common/constant/configuration/dashBoard_url_routes.dart` | Two constants (the collection, the create-form country list) and three per-record functions taking `int id`. Additive; nothing existing touched. |
| `lib/features/dashBoard/presentation/bloc/dashBoard_state.dart` | `GetLocationsStatus` and `LocationWriteStatus`; four fields; all four added to `copyWith` **and** `props`. `DashboardBloc` is a plain `Bloc`, not a `HydratedBloc`, so there is nothing on disk to migrate. |
| `assets/languages/{ar-SY,en-US,ku-IQ,tr-TR}.json` | 21 new keys, added to **all four** bundles identically. |
| `lib/generated/locale_keys.g.dart` | Regenerated by `sh keys.sh`. Not hand-edited. |
| `lib/core/di/di_container.config.dart` | Regenerated by `sh gen.sh`. Not hand-edited. |

**Ordinary paths:**

| File | Change |
|------|--------|
| `lib/features/dashBoard/data/models/get_shop_locations_model.dart` | **New.** The record, country, `meta` (`total` *and* `per_page`), the list wrapper with `loadedForSellerId`, `copyWith` on both record and wrapper, plus the lookups, edit, write and change-status responses. Coordinates parsed from strings; `status` read as "not set", never falsy. |
| `.../data_source/dashBoard_remote_data_source_model.dart` | Six methods. Each **write** passes `extraHeaders` built from one `const` key; the read does not. |
| `.../domain/repositories/dashBoard_repository.dart` + `.../data/repositories/dashBoard_repository_impl.dart` | Six interface methods and six implementations. |
| `.../domain/useCase/{get_shop_locations,get_location_form_countries,create_shop_location,get_shop_location_for_edit,update_shop_location,change_shop_location_status}_usecase.dart` | **New**, one per call. |
| `.../presentation/widgets/permission_enum.dart` | Four values. |
| `.../presentation/widgets/dashboard_permission_checker.dart` | Four methods, each `SUPER_ADMIN`-or-the-named-permission. |
| `.../presentation/bloc/dashBoard_event.dart` | Five events. |
| `.../presentation/bloc/dashBoard_bloc.dart` | Four use cases, five registrations with their transformers, five handlers, `int _locationsLoadGeneration`, the shared arrival guard, the refresh gate, and the write-status guard. |
| `.../presentation/widgets/location_form_sheet.dart` | **New.** The add/edit form. |
| `.../presentation/widgets/display_text_sanitizer.dart` | **New.** The one `AC-29` helper. |
| `.../presentation/pages/dashboard_page.dart` | `_LocationsWidgetState` rewritten against the state, the mock `LocationModel` deleted, the `case 8` call site now passes permissions, and the tab subtitle at the `_FilterItem` translated. **The tab card's `count:` was not touched.** |

**What was deliberately not touched, as the plan requires:** `get.dart`,
`put.dart`, `patch.dart`, `delete.dart` — no shared HTTP client changed, because
every write here is a `POST` and `post.dart` already honours `extraHeaders`.

## Deviations from plan

**One, and it is the unresolved blocker rather than a design change.**

**`BLK-IM3-BASE-02` was resolved by deviation, not by clearing the base.** `IM-3`
wants the ticket branch cut from `dev_new`. It could not be:

```
git diff --name-only HEAD origin/dev_new -- <the two modified files>
  -> lib/features/home/.../profile_personal_info_page.dart
```

That file **differs between `ali_dev` and `origin/dev_new` and is locally
modified**, so a checkout to the correct base would either refuse or overwrite the
owner's edit — and the owner forbade touching it. (`CLAUDE.md` is identical in both
commits and would have carried fine.)

**So the branch was cut at the current commit:** `ticket/manage-shop-locations-in-seller-dashboard`
from `ali_dev` at `1558d464`. `git status --porcelain` is byte-identical before and
after; no file was touched by the branch creation.

**What this costs, stated plainly:**

- `origin/dev_new` has moved to `16bc20a3` and is **6 commits ahead** of this base,
  with 1 commit unique to `ali_dev`. This branch is not based on what the PR will
  target.
- `/publish-pr` opens the PR against `dev_new`. Before that happens the branch
  needs rebasing onto `dev_new`, **and the two pre-existing modified files must be
  excluded from the publishable set** — they are not this work item's changes.

Both are carried into `verify.md` and are the first thing `/publish-pr` must deal
with.

## Tests written

`plan.md > Tests` declares a single row covering every `AC-n`:

| AC | Disposition | Carried out? |
|----|-------------|--------------|
| every `AC-n` (`AC-1` … `AC-35`) | `none — OQ-10 makes a manual run on a device the acceptance evidence for every criterion. No widget or bloc test is added by this work item.` | **Yes — by writing none.** `IM-11` is satisfied: the row declares no test, and none was written. |

**No test file was created.** A test the approved plan does not declare is scope
creep under `IM-4`, and the owner's widening covered defects A–D, not the Tests
row. The two candidates the plan names for a follow-up ticket — the model's
tolerant parse, and the arrival-time drop — are both pure functions and remain
good first tests when that ticket is opened.

## Findings — confirmed bugs, out of scope

### `BUG-1` — the four language bundles were already out of sync

**Scenario.** `locale-bundles-in-sync` is one of the two extra checks
`plan.md > Validation strategy` requires. It fails on this working tree, and it
failed **before this work item touched anything**.

**Confirming evidence**, taken against `HEAD`, not the working tree:

```
ar-SY  missing vs en-US: 0   extra: 1   (county_code)
ku-IQ  missing vs en-US: 0   extra: 1   (county_code)
tr-TR  missing vs en-US: 17  extra: 0
```

**Where the wrong state lives.** `assets/languages/tr-TR.json` is missing 17 keys
that `en-US.json` declares (`bad`, `buyer_rate`, `actually_received_the_product_through`,
and 14 more), and `ar-SY.json` / `ku-IQ.json` each carry a `county_code` key that
`en-US.json` does not.

**Expected vs actual.** Expected: all four bundles declare the same key set.
Actual: they have not, since before this branch existed.

**Why it is a finding and not a fix.** The bundles **are** inside
`plan.md > Files to change`, which under `IM-12` would normally make this mine to
fix. It is recorded instead for two reasons, and the owner should decide:

- fixing it means **inventing 17 Turkish translations for unrelated features**
  (reviews, ratings, buyer feedback) — that is authoring product copy, not
  repairing this work item;
- the owner's widening was explicitly scoped to defects A–D.

**This work item did not make it worse.** The 21 new keys were added to all four
bundles identically — each file went from *n* to *n + 21* — so parity for the
Locations keys is exact. **A separate ticket should close `BUG-1`.**

No strict expected-failure marker was added, because this work item adds no test
suite at all (`OQ-10`), so there is nothing to carry the marker.

## Validation run during implementation

| What | Command | Result |
|------|---------|--------|
| DI + serializers regenerated | `sh gen.sh` | **Pass.** 64 outputs written. All six use cases registered as factories; `DashboardBloc` resolves the four it needs. |
| Which generated files changed | `git status --porcelain` filtered | **Only the two the plan declares** — `di_container.config.dart` and `locale_keys.g.dart`. **No other `.g.dart` rode along**, which is what `SEC12-8` asked to be checked. |
| Localization keys regenerated | `sh keys.sh` | **Pass.** 21 `locations_*` getters present. |
| Bundle parity for the new keys | key-set comparison | **Pass** for the 21 new keys (all four bundles + 21). The **pre-existing** parity failure is `BUG-1`. |
| Static analysis | `flutter analyze` (whole package) | **Pass — 0 errors.** 13 issues, all `info`/`warning`. |

**On the remaining analyzer issues:** twelve are pre-existing (`withOpacity`
deprecations, `avoid_redundant_argument_values`, and the unused
`_confirmDeleteSelected` at `dashboard_page.dart:4350`). **One is mine:**
`DropdownButtonFormField.value` is deprecated in favour of `initialValue`
(`location_form_sheet.dart:347`). It was kept deliberately — `initialValue` makes
the field manage its own state, which would stop the picker reflecting
`setState`-driven changes. It is `info`-level, and the file matches the
surrounding code, which carries many such deprecations.

**One import detail worth recording, because it is a real trap.**
`di_container.config.dart` registers the use cases under `package:` URIs, and a
type reached through a different URI is a different type to both the analyzer and
`GetIt` — so a relatively-imported use case would compile and then fail to resolve
at run time. The form sheet therefore imports the use cases and models via
`package:`, and `DashboardBloc` relatively, matching how `dashboard_page.dart`
reaches it. This was caught by the analyzer and fixed before it could ship.

**No commit was created and nothing was pushed** (`IM-9`).

## Recommended next action

`/verify`. The profile is `codegen-change` plus the two localization checks. Two
things `verify` must handle honestly rather than around:

1. **`build-runner-clean` and `locale-keys-clean` end in `git diff --exit-code`,
   which cannot pass while the work is uncommitted** — and `IM-9` forbids
   committing. Verify the *property* the check exists for (regeneration is
   idempotent) by hashing the generated files, regenerating, and comparing.
2. **`locale-bundles-in-sync` fails for `BUG-1`**, which predates this branch.
   Record the failure, attribute it, and do not let it read as this work item's.
