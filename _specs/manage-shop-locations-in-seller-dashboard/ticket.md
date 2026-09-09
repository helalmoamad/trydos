---
ticket: manage-shop-locations-in-seller-dashboard
title: Manage Shop Locations in Seller Dashboard
workflow:
  type: development
  version: 2
  current_stage: verify
status: completed
owner: developer
created_at: 2026-08-27
updated_at: 2026-09-06
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github: ""
---

# Ticket Record — manage-shop-locations-in-seller-dashboard

> **Keep the front matter free of commentary.** The runtime parses it with a
> standard-library YAML subset reader — it does drop a trailing ` # ...` comment
> correctly, but this file is machine-owned and every field is documented in the
> reference table below. Annotate there, not in the front matter.

> **This file is the single canonical owner of the ticket's workflow state.**
> Its lifecycle position lives in exactly one field: `workflow.current_stage`
> (ADR-018). Stage artifacts (`intake.md` … `verify.md`) never own workflow
> state; their local `status` describes only their own progress. See ADR-003
> (ticket state ownership) in the `wf` plugin's `docs/adr/`.
>
> **Do not hand-edit `workflow.current_stage`, `status`, or `active_blocker_id`
> outside a transition.** They are written only by the step that records an outcome,
> following `rules/lifecycle-protocol.md` §H and §J — one edit, plus one appended
> history entry. Editing them any other way leaves a ticket whose state and history
> disagree, and since 3.0.0 nothing prevents that (ADR-023).

## Field reference

| Field | Required | Purpose | Allowed values |
|-------|----------|---------|----------------|
| `ticket` | yes | Canonical id/slug; ties artifacts + branch together. | slug `^[A-Za-z0-9][A-Za-z0-9._-]*$` |
| `title` | yes | Human-readable summary. | free text |
| `workflow.type` | yes | Which workflow this item runs. Chosen once at `/wf:start`; never changes. | `development` \| `study` \| `research` |
| `workflow.version` | yes | Ticket schema version. New tickets are `2`; legacy tickets keep `1` and are normalized in memory, never rewritten on disk (ADR-016). | `1` \| `2` |
| `workflow.current_stage` | yes | **Authoritative** lifecycle position: the stage currently active or due to execute next. There are no pseudo-stages — completion and cancellation live in `status`. | any stage id from the ticket's `workflows/<type>/workflow.yaml` |
| `status` | yes | Orthogonal health and terminal status. | `active` \| `blocked` \| `completed` \| `cancelled` |
| `active_blocker_id` | when blocked | Identity of the blocker halting progress. Set with `status: blocked`; cleared on resume. A resume must present a `ResolutionSignal` carrying this exact id. | e.g. `BLK-ACCESS-01` |
| `owner` | yes | Accountable owner. | `em` \| `developer` \| `ai_agent` \| name |
| `created_at` | yes | Creation date. | `YYYY-MM-DD` |
| `updated_at` | yes | Last transition; bumped on every stage or status change. | `YYYY-MM-DD` |
| `links` | no | Optional delivery links (metadata only; never workflow state). `github` is set by `/publish-pr`. | `{clickup, github}` URLs (may be empty) |

Stage ids and their legal transitions are defined canonically per workflow in
`workflows/<type>/workflow.yaml`. Stage names are domain-specific — `development`
runs `intake → research → spec → plan → review → implement → verify`, while
`study` and `research` have their own topologies.

### Status semantics

| Status | Meaning | Resumable |
|--------|---------|-----------|
| `active` | Work is progressing normally. | — |
| `blocked` | Non-terminal halt. `workflow.current_stage` stays put; transitions report `WORK_ITEM_BLOCKED` until an authorized resume. | yes, via `rules/lifecycle-protocol.md` §J |
| `completed` | Terminal success. `workflow.current_stage` remains the last executed stage. | no (`WORK_ITEM_TERMINAL`) |
| `cancelled` | Terminal rejection. `workflow.current_stage` remains the last executed stage. | no (`WORK_ITEM_TERMINAL`) |

## State History

Append one entry per transition; never edit or remove past entries. The command
recording the outcome writes these — the initial `ticket-created` entry at intake,
and one per transition after that (`rules/lifecycle-protocol.md` §H). This history
is the audit trail, and since 3.0.0 it is the *only* control left over the
lifecycle: nothing refuses a bad transition, so the record of what happened is what
makes one detectable.

```yaml
- to_stage: intake
  event: ticket-created
  result: passed
  by: developer
  timestamp: 2026-08-27
- from_stage: intake
  to_stage: research
  event: intake-completed
  result: passed
  by: developer
  timestamp: 2026-08-27
- from_stage: research
  to_stage: spec
  event: research-completed
  result: passed
  by: developer
  timestamp: 2026-08-27
- from_stage: spec
  to_stage: plan
  event: spec-completed
  result: passed
  by: developer
  timestamp: 2026-08-27
- from_stage: plan
  to_stage: review
  event: plan-completed
  result: passed
  by: developer
  timestamp: 2026-08-27
- from_stage: review
  to_stage: plan
  event: review-changes-requested
  result: changes_requested
  by: developer
  timestamp: 2026-08-27
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-08-27
- from_stage: review
  to_stage: plan
  event: review-changes-requested
  result: changes_requested
  by: developer
  timestamp: 2026-08-30
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-08-30
- from_stage: review
  to_stage: plan
  event: review-changes-requested
  result: changes_requested
  by: developer
  timestamp: 2026-08-30
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-08-30
- from_stage: review
  to_stage: plan
  event: review-changes-requested
  result: changes_requested
  by: developer
  timestamp: 2026-08-30
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-08-30
- from_stage: review
  to_stage: plan
  event: review-changes-requested
  result: changes_requested
  by: developer
  timestamp: 2026-08-30
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-08-30
- from_stage: review
  to_stage: implement
  event: plan-approved
  result: approved
  by: developer
  timestamp: 2026-08-31
- to_stage: implement
  event: stage-blocked
  result: blocked
  blocker_id: BLK-STEP0-CONTRACT-01
  by: developer
  timestamp: 2026-08-31
- stage: implement
  event: implementation-resumed
  result: active
  from_status: blocked
  to_status: active
  by: developer
  timestamp: 2026-08-31
  blocker_id: BLK-STEP0-CONTRACT-01
  evidence_ref: ".claude/docs/mobile-seller-dashboard-locations-api-guide.md"
- stage: implement
  event: implementation-blocked
  result: blocked
  from_status: active
  to_status: blocked
  by: developer
  timestamp: 2026-08-31
  blocker_id: BLK-PLAN-REVISION-01
- from_stage: implement
  to_stage: plan
  event: owner-authorized-replan
  result: authorized
  from_status: blocked
  to_status: active
  by: developer
  timestamp: 2026-08-31
  blocker_id: BLK-PLAN-REVISION-01
  evidence_ref: ".claude/docs/mobile-seller-dashboard-locations-api-guide.md"
  note: >-
    NOT a transition the development workflow definition declares. The implement
    stage has only success -> verify and blocked -> set_status blocked, and there
    is no route back to plan; commands/plan.md aborts unless current_stage is
    already plan. The Workflow Owner authorized this move so the plan can be
    revised against the Locations contract that closed BLK-STEP0-CONTRACT-01.
    Recorded openly under CLAUDE.md > Hard stop conditions rather than performed
    silently, and reported as a plugin defect: development.implement needs a
    needs_replan outcome with to_stage plan, the way review has changes_requested.
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-08-31
- from_stage: review
  to_stage: plan
  event: changes-requested
  result: changes_requested
  by: developer
  timestamp: 2026-08-31
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-08-31
- from_stage: review
  to_stage: plan
  event: changes-requested
  result: changes_requested
  by: developer
  timestamp: 2026-08-31
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-08-31
- from_stage: review
  to_stage: plan
  event: changes-requested
  result: changes_requested
  by: developer
  timestamp: 2026-09-01
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-09-01
- from_stage: review
  to_stage: plan
  event: changes-requested
  result: changes_requested
  by: developer
  timestamp: 2026-09-01
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-09-01
- from_stage: review
  to_stage: implement
  event: plan-approved
  result: approved
  by: developer
  timestamp: 2026-09-01
- stage: implement
  event: stage-blocked
  result: blocked
  from_status: active
  to_status: blocked
  blocker_id: BLK-IM3-BASE-02
  by: developer
  timestamp: 2026-09-01
- from_stage: implement
  to_stage: plan
  event: owner-authorized-replan
  result: authorized
  from_status: blocked
  to_status: active
  by: developer
  timestamp: 2026-09-01
  blocker_id: BLK-IM3-BASE-02
  evidence_ref: "_specs/manage-shop-locations-in-seller-dashboard/implement.md"
  note: >-
    NOT a transition the development workflow definition declares. development.implement
    has only success -> verify and blocked -> set_status blocked; there is no route back
    to plan. The owner authorized this move so one revision can close the three IM-10
    gaps review.md dispositioned as expected blockers (SR11-2, P11-1/SEC11-4, SEC11-5)
    together with the two owner answers recorded in implement.md (SEC11-3, SEC11-10).
    Recorded openly under CLAUDE.md > Hard stop conditions rather than performed
    silently. This is the SECOND such move on this work item; the first was
    BLK-PLAN-REVISION-01 on 2026-08-31.
    BLK-IM3-BASE-02 IS NOT RESOLVED by this move - the working tree is still on
    ali_dev with two unrelated modified files and no local dev_new. The condition is
    carried in plan.md > Validation strategy as a precondition and will be re-encountered
    when implement is next entered.
    Reported as a plugin defect for the third time: development.implement needs a
    needs_replan outcome with to_stage plan, the way review has changes_requested.
- from_stage: plan
  to_stage: review
  event: plan-revised
  result: passed
  by: developer
  timestamp: 2026-09-06
- from_stage: review
  to_stage: implement
  event: plan-approved
  result: approved
  by: developer
  timestamp: 2026-09-06
- stage: implement
  event: stage-blocked
  result: blocked
  from_status: active
  to_status: blocked
  blocker_id: BLK-IM3-BASE-02
  by: developer
  timestamp: 2026-09-06
  note: >-
    Second block on the same unresolved condition. The base was not cleared between
    2026-09-01 and 2026-09-06: still on ali_dev, no local dev_new, and the same two
    unrelated files modified. No branch was created and no file was touched.
    The four major defects review.md dispositioned as accept on 2026-09-06 are also
    IM-10 blockers and are recorded in implement.md; they are not part of this
    blocker id.
- stage: implement
  event: implementation-resumed
  result: active
  from_status: blocked
  to_status: active
  by: developer
  timestamp: 2026-09-06
  blocker_id: BLK-IM3-BASE-02
  evidence_ref: "git branch ticket/manage-shop-locations-in-seller-dashboard created at 1558d464; git status --porcelain unchanged"
  note: >-
    Owner authorization, 2026-09-06, recorded in the owner's own terms. THREE things
    were authorized together and none of them is a transition the definition declares.
    (1) IM-4 and IM-10 are WIDENED FOR THIS WORK ITEM ONLY: the implement stage may
    resolve review round 12's four major defects (A the drop-rule contradiction,
    B the false refetch exemption, C the two unfunded calls, D the redaction set -e
    claim) IN PLACE, without returning to plan. The design resolutions are recorded in
    implement.md > Design resolutions rather than in plan.md, because plan.md belongs
    to the plan stage and the owner directed that no further planning loop be run.
    (2) The stage is to run to completion through verify without stopping for another
    review loop.
    (3) BLK-IM3-BASE-02 is resolved by DEVIATION, not by clearing the base. The owner
    forbade stashing, committing, reverting or moving the two pre-existing uncommitted
    files. profile_personal_info_page.dart differs between ali_dev and origin/dev_new
    AND is locally modified, so a checkout to the correct base would refuse or destroy
    that edit. The ticket branch was therefore cut at the CURRENT commit (ali_dev,
    1558d464) instead of from dev_new. No file was touched: git status --porcelain is
    byte-identical before and after. The base deviation is real and is carried into
    implement.md > Deviations from plan and into verify; /publish-pr will need the
    branch rebased onto dev_new once the owner has dealt with those two files, and the
    two pre-existing modifications must be excluded from the publishable set.
- from_stage: implement
  to_stage: verify
  event: implementation-completed
  result: passed
  by: developer
  timestamp: 2026-09-06
  note: >-
    Defects A-D resolved in place under the owner-authorized widening of IM-4 and
    IM-10. flutter analyze clean across the package (0 errors). BLK-IM3-BASE-02
    resolved by deviation, not cleared: the branch was cut at ali_dev 1558d464
    because profile_personal_info_page.dart differs between that branch and
    origin/dev_new and is locally modified, and the owner forbade touching it.
    BUG-1 recorded: the four language bundles were already out of parity at HEAD.
- stage: verify
  event: verification-passed
  result: passed
  from_status: active
  to_status: completed
  by: developer
  timestamp: 2026-09-06
  note: >-
    Gate passed at attempt 3, 2/2, administered SHORT under CG-8 - two questions
    against a floor of three, and the CG-5 integration axis was not asked at this
    attempt. Attempts 1 and 2 failed (2/3, 1/2) and recorded no decision; both are
    retired to comprehension-verify-1.md and comprehension-verify-2.md.
    All four declared validation checks exit 0.
    THREE THINGS THIS COMPLETION RESTS ON, none of them hidden:
    (1) AC-16 is recorded NOT MET on the owner's explicit direction of 2026-09-06.
    The passed outcome nominally means every AC-n is satisfied and one is not;
    spec.md anticipated this and the fix is a shared-handler change in its own ticket.
    (2) Every AC-n carries CODE evidence only. The manual device run OQ-10 designates
    as the acceptance evidence for every criterion was never performed - no seller
    credentials (FINDING-2).
    (3) The branch is cut at ali_dev 1558d464, not dev_new, because
    profile_personal_info_page.dart differs between them and is locally modified and
    the owner forbade touching it. origin/dev_new is 6 commits ahead. Before
    /publish-pr the branch must be rebased and the two pre-existing modified files
    excluded from the publishable set (FINDING-3).
    BUG-1 is open: the four language bundles were already out of parity at HEAD.
    No commit was created and nothing was pushed.
```
