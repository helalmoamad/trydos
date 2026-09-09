---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-09-06
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Review — manage-shop-locations-in-seller-dashboard

> Review gate — run by the ticket owner themselves (self-review). A comprehension
> check at the gate is the integrity control. Evaluates the spec and plan before
> any implementation.

**Round 12.** The plan came back here from `implement` through an owner-authorized
replan (`BLK-IM3-BASE-02`, 2026-09-01) — the second such move on this work item.
Revision 12 was written to close three `IM-10` blockers and to record two owner
answers. This round asks whether it did.

## Review Scope

- `plan.md` revision 12 (1,764 lines), in full.
- `spec.md` — 35 acceptance criteria (`AC-1` … `AC-35`), 15 functional
  requirements, 16 open questions.
- `implement.md` — why the stage blocked, and the two owner answers recorded there
  as plan inputs.
- The previous round's findings, for what was already known and dispositioned.

Validation before the panel ran (`RV-3`), all passing: `PL-1` Approach, `PL-2`
Steps, `PL-3` Files to change, `PL-4` Validation strategy + Rollback, `PL-5` Out of
scope, `PL-11` Integration surface (explicit, and the panel re-checked its claims
against the repository — see the note under Panel Findings), `PL-12` every `OQ-n`
answered or carried in Step 0's table, `PL-13` / `PL-14` a Tests row per `AC-n`
with the search recorded, and the plan ↔ REQ/AC traceability table.

## Plan Summary

Follow the path the sibling Shop Info work item already cut, in the same files.
Add six calls to the dashboard's existing data source, repository and use case
layers; add status enums, a list field and events to the existing `DashBoardState`
and `DashboardBloc`; then replace `_LocationsWidgetState`'s mock list with that
state, gated by the existing permission checker. The add/edit form goes in its own
new file. Nothing is registered app-wide, no other tab is re-pointed, and **no
shared HTTP client is touched** — every write is a `POST`, and `post.dart` already
honours `extraHeaders`.

The tenant guard is split by direction: writes carry the captured shop id on the
request; the read is re-checked when the response arrives, against both the shop id
and a clear counter.

## Risks

- **The revision's own new text is where the panel found the most.** Three of the
  four major defects below are inside the sentences revision 12 added to fix the
  previous three. This is the fourth round in which a corrective edit introduced a
  new defect (`P9-3`, `SR11-2`, and now twice again).
- **`DashboardBloc` is an app-wide `lazySingleton` that is never disposed**, read
  by eleven tabs and by two files outside the dashboard feature —
  `become_seller_page.dart`, whose `BlocListener` has no `listenWhen`, and
  `profile_page.dart`. Every emission defect below lands there, not only on this
  screen.
- **`implement` has blocked twice on this plan already.** A gap that reaches
  `implement` costs a full off-definition lifecycle move to return here, because
  `development.implement` declares no route back to `plan`.

## Assumptions

- The manual device run is available (`OQ-10` makes it the acceptance evidence for
  every `AC-n`; the sibling work item is blocked on exactly this today).
- The contract file is complete for the six calls it documents; the field limits it
  says are unpublished stay unassumed.
- The backend accepts and stores a name carrying direction-control characters —
  which is what makes the `AC-29` manual check performable. **The panel flags this
  as unconfirmed** (`SEC12-10`).

## Open Questions

- `OQ-11`, `OQ-13`, `OQ-14`, `OQ-15`, `OQ-16` stay open, carried in Step 0's table
  with what each would move. `OQ-16` is the only one that decides an **outcome**:
  whether `AC-16` can be recorded met at `/verify`.
- `BLK-IM3-BASE-02` is **not resolved**. The checkout is on `ali_dev`, there is no
  local `dev_new`, and two unrelated files are modified. The plan carries this as a
  precondition; `implement` will meet it again.

## Panel Findings (advisory)

> Findings from the advisory review panel (senior / security / performance) —
> read-only lenses over `plan.md` + `spec.md` (ADR-010 / RP-1).
>
> **This section is written before the comprehension gate runs (RP-4).** The gate
> examines the owner on these findings, so they have to be readable first; the
> **Decision** and **Approvals** sections below are filled in afterwards.
>
> **Advisory only:** these inform the owner; they never block the decision (RP-2).

**Four distinct major defects, raised by eight major findings across three
independent lenses.** The three lenses did not see each other's work, and three of
them landed on the same two sentences. Grouped by defect, most blast radius first.

### Defect A — the drop rule contradicts itself (`SR12-1`, `SEC12-3`, `P12-1`)

Step 8's new arrival-guard rule says: "drop the response — do not write the row,
**do not emit** — and write the terminal write-status value (Step 7)". In a Bloc,
writing a state field **is** an emit. The two halves of one sentence cannot both be
carried out, so an implementer must guess — the `IM-10` shape this revision exists
to remove. If it does emit, `SEC11-5` is only half closed: no row is written, but
the emission still reaches the never-disposed singleton. All three lenses note the
terminal write is also **unnecessary**, because both drop causes run the clear
handler, which Step 7 already says resets the enum.

### Defect B — the create/update exemption rests on a false step (`SR12-3`, `SEC12-2`, `P12-2`)

Step 8 exempts create and update: "they refetch rather than write the list, and
that refetch is itself a load, which carries the guard". The guard runs **on
arrival**, and the refetch is dispatched *after* a dispose-clear has already
incremented `_locationsLoadGeneration` — so the refetch's load captures the **new**
generation, passes its own guard, and stores a full location list into the
never-disposed singleton for a screen that is gone. That is the `SR9-5` failure on
the third write path, and it contradicts Approach 3's bounded-footprint claim.

### Defect C — two of the six calls have no funded channel (`SR12-2`)

Step 8 enumerates five events; its own transformer table defines **seven**
handlers, including the create-form country list and load-for-edit. Step 7 funds no
field or status for either result. So `AC-12`'s prefill record and `AC-33`'s picker
list have no funded path from bloc to widget — **the same "no instruction at all"
shape as `SR11-2`**, which is the finding revision 12 exists to close.

### Defect D — the redaction check's silent pass returns (`SEC12-1`)

Bash disables `errexit` for commands in an `if` condition. A grep exit 2 — PCRE
error, backtrack limit, unreadable input — therefore makes the condition false,
falls through, and prints `redaction check clean`. The plan's own bullet claims the
opposite: "2 — an engine error — propagates and stops the script under `set -e`".
This is the `SEC11-2` silent pass arriving through a new door.

### Full table

| Lens | Severity | Finding | Ref (AC-n / step / file) | Owner's disposition |
|------|----------|---------|--------------------------|---------------------|
| senior | **major** | `SR12-1` — the drop rule says "do not emit" and "write the terminal write-status value" in one sentence; unimplementable, and the terminal write is unnecessary because both drop causes already run the clear | `plan.md:625-628` vs `:520-539` | **accept** — defect A. Carried into `implement` unresolved; the sentence still cannot be carried out as written. |
| security | **major** | `SEC12-3` — same contradiction; the terminal write also re-dirties the enum the clear just reset, so a dispose leaves a non-initial write status the next tab entry inherits | `plan.md:622-628` vs `:536-539` | **accept** — defect A, same sentence. The post-dispose enum state is accepted as described. |
| performance | **major** | `P12-1` — same contradiction, costed: each dropped toggle pays an O(N) `props` compare and fires `become_seller_page.dart`'s listener | `plan.md:626-629` vs `:1211-1214` | **accept** — defect A, same sentence. The per-drop compare and listener fire are accepted. |
| senior | **major** | `SR12-3` — the create/update exemption is false; the refetch captures the generation *after* the clear bumped it, so it always passes its own guard and stores a list for a dead screen | `plan.md:627-629` vs `:190-200`, `:601-605` | **accept** — defect B. The exemption sentence stays as written; the refetch path is not gated. |
| security | **major** | `SEC12-2` — same defect, framed as blast radius: a full location list is emitted into the never-disposed singleton after the screen is gone — the `SR9-5`/`SEC11-5` hole on the third write path | `plan.md:626-629` vs `:608-613`, `:615-621` | **accept** — defect B, same sentence. Emission into the never-disposed singleton after dispose is accepted. |
| performance | **major** | `P12-2` — same defect, costed: the request still goes on the wire, pays the prefs read and parses the whole page before being dropped | `plan.md:628-629` | **accept** — defect B, same sentence. The wasted request and parse are accepted. |
| senior | **major** | `SR12-2` — the create-form country list and load-for-edit appear in Step 8's transformer table but in no event list and no state field; `AC-12` and `AC-33` have no funded channel | `plan.md:590-591`, `:688-695` vs `:482-488`, `:768-769`; traceability `:1621` | **accept** — defect C. `AC-12` and `AC-33` keep no funded channel; no event or state field is added by this decision. |
| security | **major** | `SEC12-1` — `set -e` does not apply inside an `if` condition, so a grep exit 2 prints "redaction check clean"; the plan's bullet claims it propagates | `plan.md:1378-1393`, claim at `:1400-1402` | **accept** — defect D. The redaction check keeps its silent-pass path on a grep exit 2. |
| senior | minor | `SR12-4` — "emits `permissionDenied`" does not say which enum; on the read enum a write handler would replace the whole list with `AC-17`'s no-request screen | `plan.md:592-593` vs `:482-488` | |
| senior | minor | `SR12-5` — `AC-19` (hide the add control) and `AC-11` (close the form, show success) are mapped to steps that never state them | `plan.md:1617`, `:1619` vs `:997-1008`, `:815-820` | |
| senior | minor | `SR12-6` — the shop total has two homes: a state field in Step 7 and `meta.total` on the wrapper in Steps 2/11 — the two-values-can-disagree failure Step 7 avoided for the stamp | `plan.md:482-492` vs `:299-301`, `:982-983` | |
| senior | minor | `SR12-7` — the rewrite range `:3022-:3372` excludes `LocationsWidget` itself (`:3015-3020`), which must gain `required this.permissions`, and overshoots into the ShopInfo doc comment | `plan.md:1125-1130` | |
| security | minor | `SEC12-4` — Step 7's five terminal paths are listed by outcome, not structurally; any throw outside the `Either` path returns without writing one and disables every row's status control for the app's lifetime | `plan.md:520-539` | |
| security | minor | `SEC12-5` — the accepted `SEC11-10` residual names only direction-control characters, but the controller is unfiltered for everything Step 10a's strip set does not cover (`\n`, `U+2028/9`, combining marks, zero-widths, markup-looking text) | `plan.md:1716-1734` vs `:865-874` | |
| security | minor | `SEC12-6` — only `name` is bounded (255); the **address** has no length rule anywhere, and it reaches the shared request log and `HomeBloc`'s unpruned hydrated list | `plan.md:811-814`, `:748-749`, `:263-266` | |
| security | minor | `SEC12-7` — where the loaded record and country list land is undefined; if on `DashBoardState`, the clear rule does not reset them | `plan.md:591` vs `:688-695`, `:482-488` | |
| security | minor | `SEC12-8` — `sh gen.sh` regenerates `**/*.g.dart` repo-wide (a protected pattern); Files to change lists neither the new model's `.g.dart` nor a stop rule for any other regenerated file | `plan.md:1044-1048` vs `:1058-1072` | |
| security | minor | `SEC12-9` — `X-Seller-ID:\s*[0-9]+` matches only the bare header form; the log stores headers as JSON (`"X-Seller-ID": "12345"`), and a shop id under nine digits misses the digit rule too | `plan.md:1365`, claim `:1415-1421` | |
| performance | minor | `P12-3` — "a toggle's real cost" counts one emission where Step 7's shared enum requires at least two, and omits the bloc-level Equatable compare that runs before any `buildWhen` | `plan.md:653-663` vs `:520-539` | |
| performance | minor | `P12-4` — the clear's reset set is stated twice with different contents ("the list and the counter" vs "the list, the error field and the write-status enum"), and neither names `meta.total`, so the badge keeps the previous shop's total | `plan.md:532-533` vs `:695` vs `:983-996` | |
| performance | minor | `P12-5` — the restored `AC-12` bullet does not name one prefill source; doing both the carried raw record and the load-for-edit response pays two passes and can stomp typed text | `plan.md:834-842` vs `:894-896` | |
| performance | minor | `P12-6` — two of Step 7's five terminal paths are unreachable for change-status through the UI, since Step 11 hides the control without the permission | `plan.md:528-529` vs `:997-1003` | |
| senior | info | `SR12-8` — Step 11 says "delete the three `TODO` handlers", then says `_onDeactivate` "is replaced by this, not deleted" | `plan.md:947-950` vs `:1021-1025` | |
| senior | info | `SR12-9` — `meta.per_page` is carried on the model for no criterion; its only consumer is a `/verify` observation | `plan.md:299-301`, `:1086-1093` | |
| senior | info | `SR12-10` — the restored `AC-12` bullet reuses the exact phrase "stripped on the way in" that Step 10a was rewritten to disambiguate | `plan.md:838-840` vs `:902-912` | |
| senior | info | `SR12-11` — four mechanisms now serve one tenant concern on a screen that provably cannot see a shop switch while open; recorded, not raised as a cut | `plan.md:100-137`, `:990-996`, `:606-613` | |
| security | info | `SEC12-10` — Out of scope asserts a hostile name "can be saved and will be rendered", but nothing confirms the backend accepts or stores it; the same assumption makes the `AC-29` check performable | `plan.md:1716-1721`, `:936-940` | |
| security | info | `SEC12-11` — the redaction check is deliberately outside `project-config.yaml`, so the only control is a human remembering to run it; `git rev-parse --verify` proves the ref exists, not that it is current | `plan.md:1410-1413`, `:1380` | |
| performance | info | `P12-7` — the arrival guard re-reads `getXSellerId` on two handlers instead of one; cheap, no action | `plan.md:615-629` | |
| performance | info | `P12-8` — prefill-only stripping means no `TextInputFormatter`, so no regex per keystroke; revision 12 **reduced** cost here | `plan.md:902-912` | |

> **Integration surface verified against the repository** (`PL-11`). The senior lens
> re-checked the plan's claims in the source and every one held: `DashboardBloc
> extends Bloc` (not hydrated) at `dashBoard_bloc.dart:69`; `profile_page.dart` and
> `become_seller_page.dart` are the only `DashBoardState` consumers outside the
> dashboard feature, and the listener at `become_seller_page.dart:459-470` has no
> `listenWhen`; `bloc_concurrency: ^0.2.2` at `pubspec.yaml:119`; the `_FilterItem`
> subtitle and count at `dashboard_page.dart:1698-1699`; the mock `LocationModel` at
> `:2999-3013`; the `case 8` site at `:1926`. **No missing surface item was found
> beyond `SR12-2`.**

## Decision

`APPROVED`

- **Rationale.** Recorded by the owner on 2026-09-06, after the comprehension gate
  passed 3/3 with the four major defects already on disk and readable. The plan
  satisfies `RV-3` in full — `PL-1..PL-5`, `PL-11`, `PL-12`, `PL-13`, `PL-14` and
  traceability — and the approach itself has not been disputed by any finding in
  eight rounds. The panel is advisory and never blocks a decision (`RP-2`); the
  owner weighed the four majors and chose to move the work item forward rather
  than open a thirteenth revision.

> **What this decision does not do, stated plainly because the record must be
> honest.** Approving does not resolve defects A, B, C or D. Three of them are
> places where `plan.md` gives an instruction that **cannot be carried out as
> written** (A: "do not emit" and "write the terminal write-status value" in one
> sentence) or **gives no instruction at all** (C: no event, no state field and no
> status for two of the six calls). That is the `IM-10` condition. An implementer
> bound by `IM-4` may not improvise past it, and `CLAUDE.md > Hard stop
> conditions` requires a stop rather than a guess.
>
> **The predicted consequence is that `implement` blocks again**, as it did on
> 2026-08-31 and 2026-09-01. This is a prediction from the rules, not a second
> opinion on the decision — the decision is the owner's and is recorded as given.
> Returning here would need a third off-definition move, because
> `development.implement` still declares no route back to `plan`.

## Approvals

> Single self-approval by the ticket owner (no distinct reviewer, no second approver).

- Approver (owner): developer — 2026-09-06, gate record
  `comprehension.md` attempt 18, `result: passed`, `score: 3/3`,
  `evaluator.actor: owner`.

## ADR reference

- ADR: none

## Required Follow-up Actions

1. **Clear `BLK-IM3-BASE-02` before `implement` is entered.** It is still open.
   The checkout is on `ali_dev`; there is no local `dev_new`, only
   `origin/dev_new`; and `CLAUDE.md` (110 changed lines) and
   `profile_personal_info_page.dart` are modified and uncommitted. Neither is in
   **Files to change**, so `IM-4` forbids touching them and `IM-3` forbids
   carrying them onto the ticket branch. `implement.md > Recommended next action`
   lists three routes; each relocates the owner's own work, so each is the owner's
   to choose. **This stage performs none of them.**
2. **Decide, before entering `implement`, how the four accepted major defects are
   to be handled there.** Each is `IM-10`-shaped, so the implementer will stop at
   it. The options are the owner's: authorize a thirteenth plan revision that
   writes the four missing or contradictory rules; or accept a block at
   `implement` and resolve them then. Left undecided, the stage stops on the first
   one it reaches and the work item parks.
3. **Answer `OQ-16` with the backend engineer.** It does not block the build, but
   it decides whether `AC-16` can be recorded met at `/verify`. Step 0's table
   carries `OQ-11`, `OQ-13`, `OQ-14` and `OQ-15` alongside it; `OQ-16` is the one
   to ask first.
4. **Confirm device access for the manual run.** `OQ-10` makes it the acceptance
   evidence for every `AC-n`, so discovering it missing at `/verify` would waste
   the whole implementation. The sibling work item is blocked on exactly this
   today (`BLK-NO-DEVICE-RUN-01`).
5. **Carry the twelve `minor` findings into `implement` as known conditions**, not
   as work. `SR12-4`, `SR12-5`, `SR12-6`, `SR12-7`, `SEC12-4` … `SEC12-9`,
   `P12-3` … `P12-6` are each recorded above with a reference. None is dispositioned
   as required before implementation.
6. **Escalate the lifecycle gap to the Workflow Owner** — now recorded for the
   fourth time. `development.implement` needs a `needs_replan` outcome routing to
   `plan`, the way `review` has `changes_requested`; and there is no route from
   `plan` or `review` back to `spec`, with eight `spec.md` defects open behind it.
   Without both, the framework forces a choice between an honest block that goes
   nowhere and an off-definition move.
