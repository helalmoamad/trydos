---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
attempt: 10
status: complete
owner: developer
updated: 2026-08-31
result: failed
score: 2/3
threshold: 1.0
decision: none
missed:
  - "Q3 — artifact-consistency axis — SR7-7, the OQ-n id that names two different questions across spec.md and plan.md"
degraded: "3 of 3 — count met, but 1 row was admitted on a wrong blind pick despite answerable:yes; the integration question was included and cleared outright"
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Comprehension — manage-shop-locations-in-seller-dashboard

> Attempt 10 of the `review` gate. Attempts 1-9 are retired as
> `comprehension-review-1.md` … `comprehension-review-9.md` and are never edited.
>
> **This attempt failed**, but by one question rather than two. Under CG-7 the
> record below carries no option list and does not mark which answer was correct:
> the gate is re-run, and this file ships with the ticket (PB-9).

## Review gate

> Questions derived from `plan.md` revision 7 + `spec.md` + the panel findings in
> `review.md > Panel Findings` (RP-4). All three facts are ones no earlier attempt
> used (CG-7).

**Failed attempt — no answer key (CG-7).**

| # | Question (from the artifact) | Source | Axis | Falsified (CG-8) | Owner's answer | Correct? | Re-read |
|---|------------------------------|--------|------|------------------|----------------|----------|---------|
| 1 | Every write in this work item carries its shop id as a per-request header. Which shared client makes that possible, and when did it gain the ability? | `review.md > Panel Findings > SEC7-4`; `plan.md > Approach` decision 1; `plan.md > Files to change` removal note | **integration (CG-5)** | yes | `post.dart`, which already had the merge | Yes | — |
| 2 | `SR7-6` says `plan.md > Files to change` describes the route file's change in terms that no longer match Step 1. How many endpoint entries does Step 1 actually need? | `review.md > Panel Findings > SR7-6`; `plan.md > Steps 1`; `plan.md > Files to change` (`dashBoard_url_routes.dart` row) | plan-internal consistency | short | Two constants and three id functions | Yes | — |
| 3 | `SR7-7` says one `OQ-n` id is used for two different questions across `spec.md` and `plan.md`. Which id, and which two questions? | `review.md > Panel Findings > SR7-7`; `spec.md > Research Questions Resolved`; `spec.md > Non-Functional`; `plan.md > Steps 0` open table; `plan.md > Approach` decision 2 | artifact consistency | yes | `OQ-11` — the become-seller record and the picker's default | No | The id given is a **real** open question and it does appear in both files — but it names **one** question in both, which is why `SR7-7` is not about it. Read `spec.md > Research Questions Resolved` and `spec.md > Non-Functional` for what an id means there, then `plan.md > Steps 0`'s open table and `plan.md > Approach` decision 2 for what the **same** id is used to mean. The clash is the point, not the topic. |

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

## Falsification record (CG-8, ADR-028)

Five questions were drafted from five findings none of attempts 8 or 9 had used —
`SEC7-4`, `P7-1`, `SR7-4`, `SEC7-7`, `SR7-10` — and put through three rounds.

| Round | Outcome |
|-------|---------|
| 1 | Four of five answered correctly. `P7-1` (the change-status refetch) cleared. Two `construction-tell`; two `domain-knowledge` — the undeletable-entity compensation and the client-side-filter-over-a-paginated-list pitfall are both textbook, so those two **facts** were replaced rather than reworded (`SEC7-7` → `SR7-7`, `SR7-10` → `SEC7-2`). |
| 2 | `SEC7-4` and `SR7-7` cleared — blind picks wrong, `answerable: no` on both. `P7-1` flipped to a correct pick and was dropped. `SR7-4` fell to standard REST convention (a list record embedding its country object), so its fact was replaced with `SR7-6`. `SEC7-2` was still a `construction-tell`. |
| 3 | Final round. The two cleared questions were carried forward so every survivor was judged in one round; both held. `SR7-6`'s blind pick was **wrong** — it named the canonical collection-plus-`{id}` route shape, which is not what Step 1 needs. `SEC7-2` was answered correctly and dropped. |

Two questions cleared outright (`answerable: no`, blind pick wrong). One more —
the route-file question — was admitted under the degraded rule, which takes a
**miss** as at-chance evidence "whatever it said under `answerable`"; its row is
marked `short` rather than `yes`, because it was administered, not cleared.

**The count was not short, and the CG-5 integration question cleared outright and
was answered correctly.** `degraded:` records the one weaker admission, not a
missing question.

## What the re-run must do (CG-7)

- **New questions again.** Findings not yet asked in any attempt: `SEC7-1`'s
  second half (`Failure` carries only `message` and `statusCode`), `P7-2`
  (transformers), `P7-4` (the picker's item list), `P7-6`, `SEC7-5`, `SEC7-8`,
  `SEC7-9`, `SR7-9`.
- Keep the axes, including the integration axis.
- `attempt` must be **11** or higher (§G/X5); this file retires to
  `comprehension-review-10.md` when the gate is re-entered.

## Trend across the three attempts on revision 7

| Attempt | Score | What it covered |
|---------|-------|-----------------|
| 8 | 0/1 | Administered short; the CG-5 integration question could not be built |
| 9 | 1/3 | Integration question included; both shared-client questions missed |
| 10 | 2/3 | Integration question **correct**; the shared-client and route-file facts both correct |

The two facts attempt 9 missed — what revision 7 changed about the shared HTTP
clients, and what it did not — were both answered correctly here. What remains is
narrower: an id collision between two artifacts, which is a bookkeeping defect in
the plan rather than a claim about what gets built.
