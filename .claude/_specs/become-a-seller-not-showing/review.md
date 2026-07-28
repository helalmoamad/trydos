---
ticket: become-a-seller-not-showing
stage: review
mode: standard
status: complete
owner: reviewer
updated: 2026-07-18
links:
  clickup:
  github:
---

# Review — become-a-seller-not-showing

> Review gate. The reviewer evaluates the spec and plan before any implementation.

## Review Scope

Reviewed `spec.md` (REQ-1..REQ-7, NFR-1..NFR-5, CON-1..CON-4, EC-1..EC-6,
AC-1..AC-12) and `plan.md` (approach, 8 steps, files to change, validation
strategy, rollback, out of scope), against the defect recorded in `research.md`
and the ticket goal in `intake.md`. Repository state was inspected read-only at
the review; no code was run and nothing was implemented.

Reviewer: yasser.omran (`reviewer` role). Not the author of `spec.md` / `plan.md`
— both were authored by `ai_agent`/`developer` — so separation of duties (RA-3)
is satisfied without invoking the standard-mode self-review exception, which
remains disabled (`allow_self_review.standard: false`).

## Plan Summary

The seller-entry block on the profile page gates visibility on the user having a
**non-empty shop list**, so a user with no shop falls through to the hidden
branch — the action is withheld from exactly the audience it targets. The plan
inverts the gate to **ownership**: move the non-emptiness test inside the
ownership condition so an empty list reads as "not a master" and the action is
shown, while shop owners stay hidden and non-owner shop members are unaffected.

The change is confined to one widget file. The plan explicitly rejects two wider
alternatives — a derived state field (would touch a `high_risk_paths` glob and
force escalation) and null-normalising `shops` in the bloc (would alter state
shared with the shop-selection screens) — and names every adjacent file as
deliberately untouched.

## Risks

- **Scope creep into shared or high-risk surfaces** — the correct fix sits one
  refactor away from `DashBoardState` (`**/*_test.dart`-adjacent glob
  `**/*_state.dart`) and from `DashboardBloc`, either of which would breach CON-2
  or force `high_risk`. Mitigated by an unambiguous single-file "Files to change"
  list and by AC-11 making "no high-risk surface touched" a verifiable outcome.
- **No automated coverage** — the acceptance criteria are visual and
  account-shape dependent; the profile page has no test harness, so AC-1..AC-7
  rest on manual verification per account type. Accepted for a change of this
  blast radius, but it means a future regression here would not be caught by CI.
- **Newly reachable cohort exercises the unverified-phone path** — making the
  action visible to more users increases traffic through the existing
  verification/OTP branch on activation. The branch itself is untouched
  (CON-1), so this is exposure of existing behaviour, not new behaviour.
- **`shops.first` ownership semantics retained** — a multi-shop user is judged by
  one shop. Pre-existing, deliberately unchanged, and may become more visible
  once the empty case is fixed. Tracked as OQ-2, not blocking.
- **Widened `buildWhen`** — step 5 adds shop-list changes as a rebuild trigger.
  Marginally more rebuilds of one subtree on this screen; acceptable against
  NFR-2 and necessary for EC-5.

## Assumptions

- The permission response is the authoritative source of shop membership, and a
  successful response with an empty list genuinely means "this user has no shop"
  rather than a partial or paginated result.
- `GetUserPermissionEvent` is reliably dispatched for shop-less users after
  login, so `success` with an empty list is actually reached in practice — the
  plan corrects the rendering, not the fetching.
- Existing behaviour for non-owner shop members (action visible) is intentional
  and is what product wants preserved (REQ-3).
- No product requirement exists for an interim affordance for users whose seller
  request is pending (OQ-3).

## Open Questions

- OQ-1 (fail-open on retrieval failure) — resolved for this ticket as
  fail-closed, matching current behaviour. Revisit only if product disagrees.
- OQ-2 (multi-shop ownership semantics) — deferred to a separate ticket.
- OQ-3 (pending seller request affordance) — deferred to a separate ticket.
- OQ-4 (analytics on the newly visible action) — none required.

None of these block implementation; each is documented with a decided default.

## Decision

`APPROVED`

- Rationale: Plan scope is a single widget-file conditional inversion with no
  shared-state or high-risk-path impact; the `buildWhen` extension (step 5) and
  fail-closed behaviour on retrieval failure (AC-6) are both accepted as
  specified.
- Traceability confirmed (RV-3): `plan.md` satisfies PL-1..PL-5, every step
  cites the acceptance criteria it serves, and AC-1..AC-12 are each addressed by
  the approach, the validation strategy, or an explicit out-of-scope statement.
  The two judgement calls flagged before the gate — step 5's inclusion and the
  fail-closed default — were considered and are accepted, not passed over.

## Approvals

> `standard` requires 1 approver. `high_risk` requires a distinct reviewer who is
> not the plan author.

- Approver 1 (reviewer): yasser.omran — 2026-07-18
- Approver 2 (high_risk only): n/a — ticket is `standard`

## ADR reference

> Required for `high_risk`; otherwise "none".

- ADR: none — ticket is `standard` (`adr_required: false`).

## Required Follow-up Actions

- none — implementation may begin against `plan.md` as written.

Constraints carried into implementation (not follow-ups, but the boundary this
approval is granted within):

- Changes confined to `lib/features/home/presentation/pages/profile_page.dart`
  (IM-4). Touching any other file voids this approval and requires re-review.
- If the implementation turns out to require a change to `DashBoardState`,
  `DashboardBloc`, or any `high_risk_paths` glob, stop and escalate the ticket to
  `high_risk` rather than proceeding (CON-3, GU-2).
- No commit is created at `/implement` (IM-9); the delivery commit is made
  manually by the developer.
