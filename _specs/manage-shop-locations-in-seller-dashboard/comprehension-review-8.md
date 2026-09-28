---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
attempt: 8
status: complete
owner: developer
updated: 2026-08-31
result: failed
score: 0/1
threshold: 1.0
decision: none
missed:
  - "Q1 — performance / request-cost axis — P7-3, the cost revision 7 added and never recorded"
degraded: "1 of 3 — 4 questions could not clear CG-8 across three rounds; integration question excluded"
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Comprehension — manage-shop-locations-in-seller-dashboard

> Attempt 8 of the `review` gate. Attempts 1-7 are retired as
> `comprehension-review-1.md` … `comprehension-review-7.md` and are never edited.
>
> **This attempt failed.** Under CG-7 the record below carries no option list and
> does not mark which answer was correct: the gate is re-run, and this file ships
> with the ticket (PB-9), so an answer key stored beside the question would turn
> the re-run into a lookup. The next attempt asks **new** questions on the same
> axes.

## Review gate

> Questions derived from `plan.md` revision 7 + `spec.md` + the panel findings
> already written into `review.md > Panel Findings` (RP-4).

**Failed attempt — no answer key (CG-7).**

| # | Question (from the artifact) | Source | Axis | Falsified (CG-8) | Owner's answer | Correct? | Re-read |
|---|------------------------------|--------|------|------------------|----------------|----------|---------|
| 1 | Finding `P7-3` says a request cost grew in revision 7 and no step records it as accepted. Which cost? | `review.md > Panel Findings > P7-3`; `plan.md > Approach` decision 2; `plan.md > Steps 0` calls table rows 2 and 4; `plan.md > Steps 10` | performance / request cost | short | Opening the tab | No | `plan.md > Approach` decision 2 and `plan.md > Steps 10` — which call each form makes, and when. Then `plan.md > Steps 8`, which is where the pre-existing per-entry reload is decided, so the two costs can be told apart. |

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

## Why this gate was administered short (CG-8, ADR-028)

Five questions were drafted, one per `major` panel finding, and put through the
falsifier three times. The record of that, because `degraded:` is one line and
this is the reasoning behind it:

| Round | Outcome |
|-------|---------|
| 1 | All five `answerable: yes`, all `construction-tell`. Options rewritten under CG-2(e); no round consumed. |
| 2 | Q2 cleared (`answerable: no`, blind pick wrong). Q1 fell to `domain-knowledge` — generic Dio behaviour decided it — which consumed one of its two rounds and required the **fact** to change. Q3, Q4, Q5 still `construction-tell`: self-justifying clauses, a lexical echo of the stem, and broken parallelism. |
| 3 | Final round. The falsifier answered **four of the five correctly**, including Q2, which it had missed in round 2 while calling it a coin flip. Only Q5's blind pick was wrong. |

Under ADR-028 the surviving set is "the final round's questions whose blind pick
the falsifier got **wrong**" — that is Q5, and Q5 alone. The gate was therefore
administered with **one** question rather than the stage's floor of three. It was
**not** skipped, and it was not padded with questions the falsifier had answered.

**The CG-5 integration question was among those excluded.** It asked which stale
dependency survives in `plan.md > Integration surface` — the shared `PUT` client
entry that revision 7 was supposed to have removed (`SR7-5`). The falsifier picked
it correctly in the final round, so it could not be asked. Degraded mode is the
one place CG-5 may go unasked, and this line is the record that it did.

## What the re-run must do (CG-7)

- **New questions**, not these. Replaying Q5 tests memory.
- Keep the axes, including the mandatory integration axis, which this attempt
  could not cover.
- Nine `major` findings are available as sources and only one was used, so there
  is no shortage of material — the difficulty was building options the falsifier
  could not pick on shape.
- `attempt` must be **9** or higher (§G/X5), and this file is retired to
  `comprehension-review-8.md` when the gate is re-entered.
