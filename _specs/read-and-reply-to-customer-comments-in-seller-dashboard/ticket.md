---
ticket: read-and-reply-to-customer-comments-in-seller-dashboard
title: Read and Reply to Customer Comments
workflow:
  type: development
  version: 2
  current_stage: verify
status: active
owner: developer
created_at: 2026-09-09
updated_at: 2026-09-09
links:
  clickup: "https://app.clickup.com/t/z8n6b5yctu"
  github: ""
---

# Ticket Record — read-and-reply-to-customer-comments-in-seller-dashboard

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
| `workflow.type` | yes | Which workflow this item runs. Chosen once at `/wf:start`; never changes. | `development` \| `study` \| `research` \| `hotfix` |
| `workflow.version` | yes | Ticket schema version. New tickets are `2`; legacy tickets keep `1` and are normalized in memory, never rewritten on disk (ADR-016). | `1` \| `2` |
| `workflow.current_stage` | yes | **Authoritative** lifecycle position: the stage currently active or due to execute next. There are no pseudo-stages — completion and cancellation live in `status`. | any stage id from the ticket's `workflows/<type>/workflow.yaml` |
| `workflow.capabilities` | no | Owner-selected capabilities engaged for **this work item**. A tag here does nothing unless a stage of this workflow also declares it and `capabilities/<tag>/` exists; an empty list is the default and reproduces pre-v4 behaviour exactly. It selects **no stage and no transition** — a capability changes how a stage works, never which stage runs next. | list of capability ids, e.g. `[tdd]` |
| `status` | yes | Orthogonal health and terminal status. | `active` \| `blocked` \| `completed` \| `cancelled` |
| `active_blocker_id` | when blocked | Identity of the blocker halting progress. Set with `status: blocked`; cleared on resume. A resume must present a `ResolutionSignal` carrying this exact id. | e.g. `BLK-ACCESS-01` |
| `owner` | yes | Accountable owner. | `em` \| `developer` \| `ai_agent` \| name |
| `created_at` | yes | Creation date. | `YYYY-MM-DD` |
| `updated_at` | yes | Last transition; bumped on every stage or status change. | `YYYY-MM-DD` |
| `links` | no | Optional delivery links (metadata only; never workflow state). `github` is set by `/publish-pr`. | `{clickup, github}` URLs (may be empty) |

Stage ids and their legal transitions are defined canonically per workflow in
`workflows/<type>/workflow.yaml`. Stage names are domain-specific — `development`
runs `intake → research → spec → plan → review → implement → verify` and `hotfix`
runs `intake → diagnose → patch → verify`, while `study` and `research` have their
own topologies.

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
  timestamp: 2026-09-09
- from_stage: intake
  to_stage: research
  event: intake-completed
  result: passed
  by: developer
  timestamp: 2026-09-09
- from_stage: research
  to_stage: spec
  event: research-completed
  result: passed
  by: ai_agent
  timestamp: 2026-09-09
- from_stage: spec
  to_stage: plan
  event: spec-completed
  result: passed
  by: developer
  timestamp: 2026-09-09
- from_stage: plan
  to_stage: review
  event: plan-completed
  result: passed
  by: developer
  timestamp: 2026-09-09
- from_stage: review
  to_stage: implement
  event: review-approved
  result: approved
  by: developer
  timestamp: 2026-09-09
  note: >-
    Gate passed at attempt 1, 2/2, administered SHORT under CG-8 - two questions
    against a floor of three, and the CG-5 integration question was excluded
    because the falsifier answered its final form correctly. Both fact rounds and
    both option rewrites were spent; three of five questions were excluded for a
    correct blind pick. Panel returned 10 major, 12 minor, 7 info. No finding was
    dismissed: eight majors are dispositioned mitigate at implement, two accepted.
    review.md > Required Follow-up Actions carries eleven items, including three
    verified errors in the approved plan - the false step-5 claim that status
    codes survive as DioFailure, the missing clearing event for AC-4, and the
    webApp call-site count of 17 where the verified figure is 13.
- stage: implement
  event: stage-blocked
  result: blocked
  from_status: active
  to_status: blocked
  by: developer
  timestamp: 2026-09-09
  blocker_id: BLK-IM3-BASE-03
  note: >-
    IM-3 has no clean base. HEAD is 1558d464 (ali_dev tip), 1 ahead and 6 behind
    origin/dev_new; there is no local dev_new. The working tree holds 17 modified
    files and 15 untracked paths - the Locations work item's change, still
    uncommitted - and 15 of this plan's 19 files are among the modified ones.
    Cutting the branch now would carry another work item onto it, which IM-4
    forbids. CLAUDE.md and profile_personal_info_page.dart belong to neither work
    item and must be excluded from this branch on any route. No branch was
    created, no source file was edited, nothing was staged or committed.
    Three routes are listed in implement.md > Recommended next action; each
    relocates the owner's uncommitted work, so each is the owner's to choose.
- stage: implement
  event: workflow-resumed
  result: resumed
  from_status: blocked
  to_status: active
  by: developer
  timestamp: 2026-09-09
  blocker_id: BLK-IM3-BASE-03
  evidence_ref: 619f951c1ed55b57827245dddf47ea771ade0cc0
  note: >-
    Blocker cleared by owner direction. The Locations work item's change is now
    commit 619f951c on ticket/manage-shop-locations-in-seller-dashboard, pushed
    to origin. The working tree no longer carries another work item's change in
    this plan's files. CLAUDE.md and profile_personal_info_page.dart were
    deliberately excluded from that commit and remain uncommitted; neither is in
    plan.md > Files to change, so IM-4 keeps this stage away from them.
- from_stage: implement
  to_stage: verify
  event: implementation-completed
  result: passed
  by: developer
  timestamp: 2026-09-09
  note: >-
    All 14 plan steps applied on branch
    ticket/read-and-reply-to-customer-comments-in-seller-dashboard, cut from
    619f951c. Review follow-ups 2-8 applied: the clear event, a per-tab failure
    message field, a distinct loadingMore status, the ServerName named
    explicitly, in-place row patching instead of a refetch, sanitising outside
    itemBuilder at a 1000-char cap, stripDirectionControls for the dialog
    prefill, and a buildWhen over the six comments fields. detect_server.dart
    is +22/-0 - no existing arm touched (AC-35). flutter analyze: 13 issues, all
    pre-existing at HEAD, none in a file this work item created; exit code 1.
    Locale parity PASS - 27 new keys in all four bundles. Tests: none, per the
    plan's OQ-7 basis. Three findings recorded, FINDING-1 material: 403/404/429
    collapse to 400 in the shared client, so AC-26, EC-10 and EC-11 are NOT MET
    and AC-24 is partially met - the review's disposition wrongly assumed the
    fix was in scope. No commit was created for the comments change.
```
