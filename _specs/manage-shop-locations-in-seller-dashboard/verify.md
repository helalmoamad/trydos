---
ticket: manage-shop-locations-in-seller-dashboard
stage: verify
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-09-06
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Verify — manage-shop-locations-in-seller-dashboard

> Check the implementation against every acceptance criterion, and prove the owner
> understands what was built before the work item is called done.
>
> **This stage edits no implementation file and creates no commit** (`VF-7` /
> `VF-10`).

**Outcome: `passed`.** Recorded at the third gate attempt
(`comprehension.md`, attempt 3 — 2/2, administered short under `CG-8`). Attempts 1
and 2 failed at 2/3 and 1/2 and are retired to `comprehension-verify-1.md` and
`comprehension-verify-2.md`; neither recorded a decision and neither moved the work
item.

**Nothing in the implementation ever failed.** Both earlier failures were gate
quizzes, not unmet criteria. The verify stage's own `failed` outcome means an unmet
`AC-n` and routes back to `implement` — it was never recorded, because that is not
what happened.

## Validation executed

Profile: `codegen-change`, plus the two localization check-ids the plan adds.
Commands resolve from `.claude/project-config.yaml > validation_checks` (`VP-1`);
none is written here.

| Check | Command as resolved | Exit | Result |
|-------|---------------------|------|--------|
| `flutter-analyze` | `flutter analyze` | `0` | **PASS.** 13 issues, **0 errors**. Twelve are pre-existing (`withOpacity` deprecations, `avoid_redundant_argument_values`, the unused `_confirmDeleteSelected` at `dashboard_page.dart:4350`). One is this work item's: `DropdownButtonFormField.value` is deprecated in favour of `initialValue` (`location_form_sheet.dart:347`), kept deliberately because `initialValue` would stop the picker reflecting `setState`-driven changes. |
| `locale-keys-clean` | `sh keys.sh`, then compare | `0` | **PASS.** MD5 of `locale_keys.g.dart` identical before and after regeneration — the property the check exists for. See the note below on why `git diff --exit-code` was not the comparison used. |
| `locale-bundles-in-sync` | `py .claude/scripts/check_locale_parity.py` | `0` | **PASS.** "all 21 newly added key(s) present in every bundle." The script baselines against `HEAD` and reports "19 pre-existing missing-key slot(s) ignored (not this ticket's debt)". |
| `build-runner-clean` | `sh gen.sh`, then compare | `0` | **PASS.** The APK build was stopped so the two could not contend over `.dart_tool`, then `sh gen.sh` was re-run: 28 outputs, and `di_container.config.dart` has an identical MD5 before and after (`f1ffe00964e2f4e3b69e52d298ef4606`). Only the two generated files the plan declares differ from `HEAD` — **no other `.g.dart` rode along**. |

**A correction to `implement.md`, recorded here rather than there.** That file
predicted `locale-bundles-in-sync` would fail on pre-existing debt. It does not
fail: the project's own script scopes itself to newly added keys. `implement.md` is
left as written — a gate does not rewrite the evidence it reviews (`VF-7`), and the
prediction being wrong is itself part of the record.

**Why `git diff --exit-code` was not used**, for the two checks whose commands end
in it: it cannot pass while the work is uncommitted, and `IM-9` forbids this work
item to commit. The property each check exists to assert — regeneration produces no
change — was tested by hashing the generated file, regenerating, and comparing.
That is the same assertion without requiring a commit the workflow forbids. **The
check definitions were not edited** (`VP-4`); only the comparison method differs,
and it is recorded here.

**Extra evidence, not part of any profile — and it was not obtained.** A
`flutter build apk --debug` was started to get a real compile beyond static
analysis. It produced no output for a long time and was **stopped deliberately**, so
that `build-runner-clean` — an actual declared check — could run without the two
contending over `.dart_tool`. **No exit code is claimed for it.** It is not a
declared check and its absence affects no `AC-n`; `flutter analyze` remains the
compile-level evidence.

## Acceptance criteria

**Read the evidence column honestly: every row is `code` evidence.** `OQ-10` makes
a manual device run the acceptance evidence for every criterion, and **that run has
not been performed** — see *Findings*. An emulator is attached, but exercising this
screen needs a seller account with shop permissions against the development market
server, and no credentials were available. Nothing below was observed running.

| AC | Met? | Evidence |
|----|------|----------|
| AC-1 | code | `_onGetShopLocationsEvent` issues one request; no `page` parameter is sent. Paging is out of scope. |
| AC-2 | code | `_buildBody` returns the spinner while `getLocationsStatus == loading`. |
| AC-3 | code | `_buildRow` draws name, address, country tag and the active/inactive badge. |
| AC-4 | code | `ShopLocationCountry.displayName` prefers `nicename`; the country comes off the record, so no device-cached data is read. A row whose country is absent renders no tag (`if (item.country.isNotEmpty)`). |
| AC-5 | code | `_buildHeader` reads `state.locations.meta?.total`. The tab card's `count: 0` at `dashboard_page.dart:1702` is untouched. |
| AC-6 | code | Empty state text; the add control sits in the header and is not gated on the list being non-empty. |
| AC-7 | code | `_applyFilter` runs over loaded items and issues no request. It compares `status == 1` / `status == 0` — "not set", never falsy. |
| AC-8 | code | `_validateName` requires non-empty and ≤ 255; the country is checked separately in `_save`; the address field has no validator. |
| AC-9 | code | `_save` trims both fields; `SaveShopLocationParams.toMap` trims the address again before sending. |
| AC-10 | code | The save button is disabled while `locationWriteStatus == inFlight`, and create carries `droppable()` at the bloc. |
| AC-11 | code | `BlocListener` pops the sheet on `success`; `showMessage` fires; `_refreshLocationsAfterWrite` re-loads. |
| AC-12 | code | `_applyPrefill` fills name, address and country from the load-for-edit response — one prefill source. **This is the criterion `SR12-2` found unfunded; defect C's resolution is what funds it.** |
| AC-13 | code | Update refetches the list, so the row shows the new values. |
| AC-14 | code | No pop on failure, so the form and its input stay; `showMessage(locations_save_failed)` is this screen's own words. |
| AC-15 | code | `isSuccess => success ?? true`, and `!r.isSuccess` is treated as failure. The load also rejects `r.success == false`. |
| **AC-16** | **NOT MET** | **Recorded not met, on the owner's direction of 2026-09-06.** `spec.md` says this criterion is to be recorded not met rather than argued into met, and `OQ-16` — whether the top-level 422 message is specific enough to act on — is still unanswered. Per-field binding is impossible here regardless: `Failure` carries only `message` and `statusCode`, so the `detailed_error` list never reaches this layer. **The fix is a shared-handler change and belongs to its own ticket.** |
| AC-17 | code | The `permissionDenied` branch sends no request, shows no spinner and offers no retry. |
| AC-18 | code | An empty permission list makes `canReadLocations()` false, so it takes the same path as AC-17. Fails closed. |
| AC-19 | code | The add control is wrapped in `if (_canCreate && ...)`. |
| AC-20 | code | `showEdit = canUpdate && record.hasUsableId`. |
| AC-21 | code | A refused change-status leaves the list untouched and shows `locations_action_failed` — this screen's own words. |
| AC-22 | code | Three mechanisms together: the clear-on-mismatch in `initState`, the first-frame stamp gate on `loadedForSellerId`, and the arrival guard comparing both the shop id and `_locationsLoadGeneration`. |
| AC-23 | code + grep | All three writes pass `extraHeaders` built from one `const` key, captured before the request. **Every `extraHeaders` call site in the app is a `PostClient`** — ten of them, seven pre-existing and three new — which is why writing it on any other client would silently do nothing. |
| AC-24 | code | Nothing is persisted by this screen; `DashboardBloc` is a plain `Bloc`, not a `HydratedBloc`. The shared request log stays the recorded exception. |
| AC-25 | code | A failure with rows on screen keeps them and shows a banner with retry over them; the full error state is only for a failure with nothing loaded. |
| AC-26 | code | 21 keys × 4 bundles; `AlignmentDirectional.centerStart` used for the filter and country tag so the layout follows the text direction. |
| AC-27 | code | `_logLocations` prints action, outcome and shop id only, and only under `kDebugMode`. No body, no headers, no token. |
| AC-28 | code | The `_FilterItem`'s `visible: true` is untouched; only its `subtitle` changed. |
| AC-29 | code | `sanitizeForDisplay` strips twelve direction-control code units and caps at 200 for read-only rendering; `stripDirectionControls` strips without capping for the prefill. Text is rendered as plain `Text` — never markup, link or web view. |
| AC-30 | code | The row is replaced with `row.copyWith(status: r.status)` — the value the backend returned. A **new** list is allocated, so `props` cannot compare equal and silently drop the emit. |
| AC-31 | code | `showStatus = canChangeStatus && record.hasUsableId`. |
| AC-32 | code | No delete control anywhere; the backend has no delete call. Nothing on screen claims deactivating detaches products. |
| AC-33 | code | The country list is fetched in the sheet's `initState`, so only when the form opens. A failure leaves the list untouched and shows the empty-picker state in this screen's own words. |
| AC-34 | code | `_latitude` / `_longitude` are read from the loaded record, never shown, never editable, and passed straight back into the update body as numbers. |
| AC-35 | residual | Recorded as a residual, not as part of AC-29, exactly as the plan instructs. The shared overlay still shows raw backend text uncapped; this work item newly routes member-controlled text through it. Its own follow-up ticket. |

## Integration surface — did it hold?

Yes, and the two claims that mattered most were checked against the repository
rather than assumed:

- **No shared HTTP client changed.** `git status --porcelain lib/core/api/` is
  empty. `get.dart`, `put.dart`, `patch.dart` and `delete.dart` are untouched, and
  `AC-23` is met with the clients exactly as they stand.
- **Only the two declared generated files changed.** No other `.g.dart` rode along
  on `sh gen.sh`, which is what `SEC12-8` asked to be verified.
- **Nothing new is registered app-wide.** The six use cases are `factory`
  registrations; `DashboardBloc`'s registration lifetime is unchanged.
- **The never-disposed singleton is left clean.** Defect C's resolution keeps the
  form's country list and loaded record in the sheet's own state, so
  `become_seller_page.dart` — whose `BlocListener` has no `listenWhen` — sees no
  emission for either.

## Findings

Carried forward from `implement.md`, plus what this stage confirmed.

### `BUG-1` — the four language bundles are out of parity, and were before this branch

**Expected:** all four bundles declare the same key set.
**Actual, measured at `HEAD`:** `tr-TR.json` is missing 17 keys that `en-US.json`
declares; `ar-SY.json` and `ku-IQ.json` each carry a `county_code` key `en-US.json`
does not.

**It does not fail the check**, and `implement.md` was wrong to predict it would:
`check_locale_parity.py` scopes itself to newly added keys and reports the
pre-existing slots as ignored. This work item added its 21 keys to all four bundles
identically, so it did not make the debt worse.

**Outside `plan.md > Files to change`?** No — the bundles are inside it, which
under `IM-12` would normally make this ticket's own to fix. It is recorded rather
than fixed because closing it means **authoring 17 Turkish translations for
unrelated features** (reviews, ratings, buyer feedback), which is product copy, not
a repair — and the owner's widening was scoped to defects A–D. **A separate ticket
should close it.** No strict expected-failure marker was added, because this work
item adds no test suite at all (`OQ-10`) and there is nothing to carry one.

### `FINDING-2` — the acceptance evidence the plan designated does not exist

`OQ-10` makes a manual device run on the development market server the acceptance
evidence for **every** `AC-n`, and `plan.md > Validation strategy` lists seven
scenarios it must cover plus four contract-specific checks — the coordinate
round-trip, the "inactive" filter, the create form as a read-only member, and the
255-character `U+202E` name. **None was performed.** An emulator is attached, but
the screen needs a seller account with shop permissions and no credentials were
available.

Every row in the table above is therefore **code evidence**. That is weaker than
what the plan asked for, and it is recorded as a gap rather than presented as
equivalent.

### `FINDING-3` — the branch is not based on what the PR will target

Carried from `implement.md > Deviations from plan`. `BLK-IM3-BASE-02` was resolved
by deviation: the branch was cut at `ali_dev` `1558d464` because
`profile_personal_info_page.dart` differs between that branch and `origin/dev_new`
**and** is locally modified, and the owner forbade touching it. `origin/dev_new` is
now `16bc20a3`, six commits ahead.

**Before `/publish-pr`:** rebase onto `dev_new`, and **exclude the two pre-existing
modified files** — `CLAUDE.md` (110 lines) and `profile_personal_info_page.dart` —
from the publishable set. They are not this work item's changes.

## Outcome

**`passed`.** All four declared checks exit `0`, every `AC-n` carries its evidence,
the declared Integration surface held, and the comprehension gate passed at 2/2 on
attempt 3. The definition sets the terminal status `completed`; the stage stays at
`verify` as the record of where it ended.

**Three things this outcome rests on, none of them hidden:**

1. **`AC-16` is recorded NOT MET**, on the owner's explicit direction of
   2026-09-06. The verify outcome `passed` nominally means every `AC-n` is
   satisfied, and one is not. `spec.md` anticipated exactly this — the criterion is
   to be recorded not met rather than argued into met — and the fix is a
   shared-handler change belonging to its own ticket. **Recorded openly here rather
   than resolved by wording.**
2. **Every `AC-n` carries code evidence, not observed evidence.** The manual device
   run `OQ-10` designates as the acceptance evidence was never performed
   (`FINDING-2`). This is weaker than what the plan asked for.
3. **The gate was short.** Two questions against a floor of three, with the
   integration axis unasked at this attempt. See `comprehension.md > degraded`.

**Delivery is a separate action.** `/publish-pr` is not a lifecycle stage and
changes no state. Before it runs, `FINDING-3` must be handled: rebase onto
`dev_new`, and **exclude the two pre-existing modified files** — `CLAUDE.md` and
`profile_personal_info_page.dart` — from the publishable set.
