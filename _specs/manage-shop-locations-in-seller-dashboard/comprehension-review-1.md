---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
attempt: 1
status: complete
owner: developer
updated: 2026-08-27
result: passed
score: 5/5
threshold: 1.0
decision: CHANGES_REQUESTED
missed:
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Comprehension — manage-shop-locations-in-seller-dashboard

> Single-owner gate control (ADR-009 / ADR-012 / CG-1..CG-7). The owner answered
> multiple-choice questions generated from `plan.md`, `spec.md`, and the panel
> findings already written to `review.md > Panel Findings` (RP-4). Options are
> listed alphabetically so position carries no signal. The gate records a
> decision only at 100% (CG-4).
>
> Five questions were asked: the floor is three, and the panel returned **eight**
> `major` findings, which under CG-6 would add eight. The ceiling is five, so the
> mandatory integration question was kept and the remaining room spent on the
> findings with the largest blast radius; question 5 covers two related security
> majors. Every `major` is still dispositioned in `review.md` — the ceiling caps
> questions, not accountability.

## Review gate

| # | Question (from the artifact) | Source (plan §/AC-n/panel:lens) | Axis | Options (correct + distractors) | Owner's answer | Correct? |
|---|------------------------------|---------------------------------|------|---------------------------------|----------------|----------|
| 1 | Per `plan.md > Integration surface`, what is the concrete failure if a field is added wrongly to the shared dashboard state? | `plan.md > Integration surface` | integration (CG-5) | **Every dashboard tab can break** (correct — all eleven rebuild from one shared state object) · Only the Locations tab breaks · The app fails to compile · The failure appears after a restart | Every dashboard tab can break | Yes |
| 2 | The senior lens flagged the country picker as a major finding. What is the app-wide blast radius it identified? | panel:senior (major); `plan.md` Step 10 | integration / blast radius | It causes the country list to reload constantly · It leaks the seller's location to other tenants · It overwrites the shop's saved address · **It re-points the whole app's browsing country** (correct — the dropdown writes country into prefs, and `base_api` builds every request's `country` header from those values) | It re-points the whole app's browsing country | Yes |
| 3 | Both the senior and security lenses say `AC-18` cannot be satisfied as written. Why not? | panel:senior + panel:security (major); spec AC-17, AC-18 | correctness of acceptance criteria | Because the backend rejects a request with no permission header · **Because the permission list arrives as an empty list on failure** (correct — "failed to load" and "grants nothing" are indistinguishable) · Because the permission strings are still unconfirmed · Because the read permission is checked on the tab list | Because the permission list arrives as an empty list on failure | Yes |
| 4 | What did the senior lens find wrong with `AC-5` (the location count)? | panel:senior (major); spec AC-5; plan Out of scope | scope consistency | **AC-5 conflicts with the plan's Out of Scope** (correct — the tab-card count lives in the shared tab list the plan promised not to touch) · AC-5 duplicates AC-1 and should be deleted · AC-5 is untestable because no total is returned · AC-5 requires an endpoint the plan omits | AC-5 conflicts with the plan's Out of Scope | Yes |
| 5 | The security lens says `AC-23` does not close the window it claims to. What is the residual risk? | panel:security (major, covers two related findings); spec AC-23; plan Step 8, Rollback | tenant safety / irreversibility | **A create can still land on the wrong shop** (correct — the seller id header is read at request-build time, not at dispatch, and a created location cannot be deleted) · A create is retried automatically on a slow network · The save is blocked while another tab loads · The wrong shop's locations are shown, but nothing is written wrongly | A create can still land on the wrong shop | Yes |

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

## Verify gate

> Not applicable to this record. The verify gate earns its own
> `comprehension.md` with `stage: verify`, after this record is retired to
> `comprehension-review-1.md` on the next entry into a gated stage
> (`rules/lifecycle-protocol.md` §G/E1).
