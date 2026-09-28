---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
attempt: 9
status: complete
owner: developer
updated: 2026-08-31
result: failed
score: 1/3
threshold: 1.0
decision: none
missed:
  - "Q1 — error-path axis — SR7-1 / SEC7-1, what survives to the repository when a write is refused"
  - "Q2 — integration axis (CG-5) — plan.md > Files to change, the protected runtime paths this work item touches"
degraded: "3 of 3 — count met, but 2 rows were admitted on a wrong blind pick despite answerable:yes; the integration question was included, not excluded"
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Comprehension — manage-shop-locations-in-seller-dashboard

> Attempt 9 of the `review` gate. Attempts 1-8 are retired as
> `comprehension-review-1.md` … `comprehension-review-8.md` and are never edited.
>
> **This attempt failed.** Under CG-7 the record below carries no option list and
> does not mark which answer was correct: the gate is re-run, and this file ships
> with the ticket (PB-9). The next attempt asks **new** questions again.
>
> Attempt 8 was administered short at one question. This attempt filled the floor
> — three questions, including the mandatory integration question that attempt 8
> could not cover — so the two failures below are on the substance, not on a thin
> gate.

## Review gate

> Questions derived from `plan.md` revision 7 + `spec.md` + the panel findings in
> `review.md > Panel Findings`, which were written before any question was asked
> (RP-4) and were re-read before this attempt (CG-7).

**Failed attempt — no answer key (CG-7).**

| # | Question (from the artifact) | Source | Axis | Falsified (CG-8) | Owner's answer | Correct? | Re-read |
|---|------------------------------|--------|------|------------------|----------------|----------|---------|
| 1 | What does the repository layer receive when a write to these endpoints is refused? | `review.md > Panel Findings > SR7-1` and `SEC7-2`; `plan.md > Steps 3` last bullet; `plan.md > Follow-ups` round 6 item 1 | error path | yes | `ServerFailure` carrying the top-level `message`, status 422 | No | `review.md > Panel Findings > SR7-1`, which traces the path end to end and names the three files it passes through. The answer given is what revision 7 **claimed** and what the panel disproved — that is the whole finding. |
| 2 | `plan.md > Files to change` opens with the protected runtime paths this work item touches. Which set does it list? | `plan.md > Files to change` (protected block); `CLAUDE.md > Project profile` protected runtime paths | **integration (CG-5)** | short | `dashBoard_url_routes.dart`, `post.dart`, the four language bundles, and the generated key file | No | `plan.md > Files to change` — read the protected block itself, including the two block-quoted **removal** notes. One shared HTTP client was taken out of that list by revision 7; none was put in. Then `plan.md > Integration surface`, where `SR7-5` found the contradiction. |
| 3 | Step 11 holds one thing back pending an `OQ-n`. `SR7-3` says that hedge now contradicts the traceability table's own mapping of Step 11. Which hedge? | `plan.md > Steps 11`; `plan.md > Plan ↔ REQ / AC traceability` row 11; `spec.md > Amendment A-6` | plan ↔ AC traceability | short | Deactivate control / `OQ-6` | Yes | — |

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

## Falsification record (CG-8, ADR-028)

Five questions were drafted from five different `major` findings and put through
three rounds. All five facts differed from attempt 8's.

| Round | Outcome |
|-------|---------|
| 1 | All five answered correctly. Four `construction-tell` — in every case the correct option was the only "negative", "withholding" or "odd one out" among parallel positives. One `domain-knowledge`: the `initState` timing question was answerable from generic Flutter behaviour, so that **fact** was replaced rather than reworded. |
| 2 | All five answered correctly again. The tells moved into the **stems** — "no source and no reader", "passes through the shared client before the repository sees it", "argues that description is now wrong" each telegraphed the shape of the answer — plus cross-question leakage: Q1's options named `post.dart`, which settled Q3. |
| 3 | Final round. Stems neutralised, the leaking option removed, and all four options in the Step 11 question made to cite an open question. **The falsifier's blind pick was wrong on three of the five.** |

The three it got wrong are the three asked. Two of them it still reported as
`answerable: yes`; under ADR-028 a **miss** is the at-chance evidence this check
exists to obtain, "whatever it said under `answerable`", so they were admitted and
their rows are marked `short` rather than `yes` — administered, not cleared. The
error-path question cleared outright (`answerable: no`, blind pick wrong).

**The count was not short.** Three questions is the stage floor, and the CG-5
integration question was among them — unlike attempt 8, where it had to be
excluded. `degraded:` records the weaker admission basis, not a missing question.

## What the re-run must do (CG-7)

- **New questions again.** Six `major` findings remain unused as question sources:
  `SEC7-2`, `P7-1`, `P7-2`, `P7-3`, `P7-4`, and the `SR7-5` Integration surface
  finding in a form not yet asked.
- Keep the axes, including the integration axis.
- `attempt` must be **10** or higher (§G/X5); this file retires to
  `comprehension-review-9.md` when the gate is re-entered.
- The two missed questions point at the same underlying thing from two sides —
  **what revision 7 actually changed about the shared HTTP clients, and what it
  did not.** That is the material to re-read before the next attempt.
