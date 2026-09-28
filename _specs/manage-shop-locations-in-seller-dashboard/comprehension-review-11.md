---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
attempt: 11
status: complete
owner: developer
updated: 2026-08-31
result: passed
score: 3/3
threshold: 1.0
decision: CHANGES_REQUESTED
missed:
degraded: "3 of 3 — count met, but all three rows were admitted on a wrong blind pick despite answerable:yes, and the CG-5 integration question was excluded"
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Comprehension — manage-shop-locations-in-seller-dashboard

> Attempt 11 of the `review` gate, and the first to pass. Attempts 1-10 are
> retired as `comprehension-review-1.md` … `comprehension-review-10.md` and are
> never edited.
>
> **This attempt passed**, so CG-2's full record is written below, with the option
> lists and the correct answers marked. No re-run follows, so there is no answer
> key to protect.

## Review gate

> Questions derived from `plan.md` revision 7 + `spec.md` + the panel findings in
> `review.md > Panel Findings` (RP-4). All three facts are ones no earlier attempt
> used (CG-7). All three are **two-hop** — each needs two places joined, which
> satisfies CG-2(d)'s "half, rounded up" with room to spare.

| # | Question (from the artifact) | Source (plan §/AC-n/panel:lens) | Axis | Hops | Options (correct + distractors) | Falsified (CG-8) | Owner's answer | Correct? |
|---|------------------------------|---------------------------------|------|------|---------------------------------|------------------|----------------|----------|
| 1 | `plan.md > Validation strategy` lists two things to confirm before `implement` begins. Which two? | `plan.md > Validation strategy`; `plan.md > Steps 0` ("None is a precondition for `implement`"); panel: `SR7-11` | plan-internal consistency | 2 | **Device access for the manual run, and the backend engineer's availability** ✔ · A test shop on the development server, and device access for the manual run · A test shop on the development server, and the redaction grep's result · The backend engineer's availability, and the redaction grep's result | short | Device access for the manual run, and the backend engineer's availability | **Yes** |
| 2 | How many location rows does the state hold after one load? | `plan.md > Steps 7`; contract §1 (`meta`, `pagination_limit`); panel: `P7-6` | resource bound | 2 | **As many as the response returns, bounded by the shop's `pagination_limit`** ✔ · As many as the display copy's cap allows, set by Step 10a · As many as the member scrolls to, since the list builds lazily · As many as the response returns, bounded by the `per_page` the request sends | short | As many as the response returns, bounded by the shop's `pagination_limit` | **Yes** |
| 3 | The edit form issues a load-for-edit call even though the list row already holds the record. What does that call supply that the row does not? | `plan.md > Approach` decision 2 (edit-form bullet); `plan.md > Steps 0` call 4; contract §4; panel: `SR7-12` | approach justification | 2 | **The record's country list, which the row does not carry** ✔ · The record's coordinates, which the list omits · The record's status, which the list omits · The record's unique-name check, which the row cannot run | short | The record's country list, which the row does not carry | **Yes** |

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

## Falsification record (CG-8, ADR-028) — and why `degraded:` is set on a pass

Five questions were drafted from findings no earlier attempt had used, and put
through three rounds.

| Round | Outcome |
|-------|---------|
| 1 | Nothing survived. Four answered correctly on shape; one (`SR7-9`, the filter sub-bullet) had a genuinely incoherent cell in its 2x2 grid, which the falsifier used to eliminate. Four facts replaced. |
| 2 | One miss (`P7-6`). The rest fell to a vocabulary mismatch between stem and options, to overlap counting (one element appearing in three of four options), and to a stem still naming shared state as a growth risk. |
| 3 | Final round. Vocabulary unified, the option set rebalanced so each element appears in exactly two options, the risk framing removed. **Three of the five blind picks were wrong** — those three were asked. |

**`degraded:` is set even though the count was met and the score is 3/3.** Two
things are recorded there honestly rather than glossed:

1. **All three rows were admitted on a miss, not on a clean clear.** The falsifier
   still reported `answerable: yes` on each; ADR-028 admits them because a wrong
   blind pick is the at-chance evidence this check exists to obtain, "whatever it
   said under `answerable`". Their `Falsified` column therefore reads `short` —
   administered, not cleared — and must not claim otherwise.
2. **The CG-5 integration question was excluded.** It asked what this work item
   changes inside the shared dashboard tab list — the `subtitle:` line and nothing
   else, with the tab card's `count:` untouched. The falsifier answered it
   correctly in the final round, so it could not be asked. The other dropped
   question was the arrival-guard comparison.

Degraded mode is the one place CG-5 may go unasked, and this is the record that it
did. Across the four attempts on revision 7 the integration axis was asked twice
(attempts 9 and 10) — missed once, then answered correctly.

## The four attempts on revision 7

| Attempt | Score | Result | Integration question |
|---------|-------|--------|----------------------|
| 8 | 0/1 | failed | could not be built |
| 9 | 1/3 | failed | asked — missed |
| 10 | 2/3 | failed | asked — correct |
| 11 | 3/3 | **passed** | excluded (falsifier answered it) |

Eleven attempts is not a normal gate history, and most of it belongs to the
falsifier rather than the owner: attempts 8 and 11 were shortened or weakened by
questions the falsifier could answer blind, which is CG-8 working as designed —
it rejects questions that test nothing. What the owner was actually asked across
attempts 9-11 was ten questions, of which six were answered correctly, and the
three that decided this gate were all two-hop.
