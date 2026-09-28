---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
attempt: 16
status: complete
owner: developer
updated: 2026-09-01
result: passed
score: 3/3
threshold: 1.0
decision: CHANGES_REQUESTED
missed:
degraded: "3 of 3 asked, but only 2 survived falsification cleanly — below the floor of 3, so the gate was administered short under CG-8 / ADR-028. Three regeneration rounds were spent. Q3 (which OQ-n stay open) and Q4 (the tab-list line numbers) were discarded because the falsifier's blind pick was correct. Q5 was admitted under the degraded rule only — the falsifier's pick was wrong, but it reported answerable: yes on a construction-tell. The CG-5 integration question was NOT excluded and was asked as Q1. CG-6 seeding is the real casualty: ten major findings were raised, and the question facts that carried the majors (the five-versus-four open-question count for SR10-1, and Step 7's field list for SR10-3 / P10-2) are exactly the ones that could not clear CG-8."
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Comprehension Record — review gate, attempt 16

> The single-owner workflow has no second reviewer (ADR-009). This record is the
> control against rubber-stamping: the owner answered questions generated from
> `plan.md` and `spec.md`, closed-book, after reading
> `review.md > Panel Findings`.
>
> **Pass is 100%** (`CG-4`). Anything less records no decision.

## How this set was built

Five questions were drafted from `plan.md` revision 10, `spec.md`, and the ten
`major` panel findings written to `review.md` at Step 2. Every option names
something that exists in this project; distractors are the correct fact
minimally perturbed.

**Three falsification rounds were run** (`CG-8`). The falsifier receives the
questions and their options alone — no plan, no spec, no ticket, no repository —
and is never told which option is correct. A question it answers correctly, or
can justify, is not testing the artifact.

| Round | Asked | Outcome |
|-------|-------|---------|
| 1 | Q1 `extraHeaders` client, Q2 sanitizer count, Q3 open-question count, Q4 Step 7 fields, Q5 confirm step | Only **Q2** survived. Q1's blind pick was correct. Q3, Q4 and Q5 were `answerable: yes` on construction tells; Q4's blind pick was also correct. |
| 2 | Q1 (new fact — Integration surface), Q3, Q4, Q5 (options rewritten) | **None** survived. Q3 and Q4 blind picks correct; Q1 and Q5 `answerable: yes`. Q4's basis was `domain-knowledge`, so its fact was changed rather than its wording. |
| 3 | Q1 (options rewritten), Q3 (new fact), Q4 (new fact), Q5 (options rewritten) | **Q1 and Q2 survive cleanly.** Q3 and Q4 discarded — blind picks correct. Q5's pick was wrong but `answerable: yes`. |

Rounds are spent. Two clean survivors is below `gate.min_questions` of 3, so the
gate was **administered short rather than skipped** (`CG-8`, ADR-028): the final
round's questions whose blind pick the falsifier got **wrong** were asked. That
is Q1, Q2 and Q5. `CG-4`'s 100% applies to what was actually asked.

**What this costs, stated plainly.** `CG-6` asks for one question per `major`
finding, and there are ten. The facts that carried the majors are the ones that
could not clear `CG-8` — the open-question count (`SR10-1`) and Step 7's field
list (`SR10-3`, `P10-2`) were both discarded because a model with no artifact
picked them correctly. Only `SR10-2` is examined below. The other nine majors
are dispositioned in `review.md` without a question behind them.

## Questions asked

| # | Axis | Two-hop | Falsified | Answer given | Correct |
|---|------|---------|-----------|--------------|---------|
| Q1 | Integration / cross-flow (`CG-5`) — `plan.md > Integration surface` | no | yes | Orders builder, route | ✅ |
| Q2 | The sanitizer's stated contents — Step 10a vs round 9's follow-up table | yes | yes | Twelve / nine | ✅ |
| Q5 | The create-confirm claim — Step 0's `OQ-14` row vs `Rollback` (`SR10-2`) | yes | short | Withdrawn / kept | ✅ |

**Score: 3/3.** Two of the three required joining two places in the artifacts.

### Q1 — integration surface (`CG-5`)

*`plan.md > Integration surface` records one worry raised in an earlier review
round as **not a risk**, so it is not raised again, and gives the reason. Which
worry, and which reason?*

**Answered: the orders builder rebuilding with no `buildWhen`; not a risk
because every tab is its own pushed route.** Correct. Integration surface records
that revision 3 warned this screen's emissions would rebuild the orders builder
at `dashboard_page.dart:2056`, which has no `buildWhen` — and that this is
unreachable, because every tab is its own pushed route, so Orders and Locations
are never mounted together. The parent builder's `buildWhen` on four unrelated
statuses is a second, weaker sentence in the same entry, and the shop-switcher
argument belongs to `AC-22`, not to this one. The become-seller listener's
missing `listenWhen` is a **real** dependency in the same section, not a
dismissed one — which is what made it the right distractor.

### Q2 — the sanitizer's stated contents

*Step 10a lists the exact code points the display sanitizer strips — the list
`AC-29` is verified against. Round 9's follow-up table states a count for that
same list. What do the two say?*

**Answered: Step 10a lists twelve code points, but the follow-up table says
nine.** Correct. Step 10a names `U+202A`–`U+202E` (five), `U+2066`–`U+2069`
(four), `U+200E`, `U+200F` and `U+061C` — twelve — while round 9's follow-up row
calls it "the nine stripped code points". This is `SEC10-6` and the `P10` echo of
it: a number stated twice and agreeing once, inside the very revision that
restored the list. The security lens also confirmed the set is exactly the
Unicode `Bidi_Control` block, so the list is right and only the count is wrong.

### Q5 — the create-confirm claim (`SR10-2`, degraded admission)

*Step 0's `OQ-14` row and the `Rollback` section each mention a confirmation step
for creating a location. What does each say about it?*

**Answered: Rollback says the claim is withdrawn; Step 0's `OQ-14` row says one
is kept.** Correct. `Rollback` states outright that "no step builds a
confirmation and no criterion covers one … the claim is withdrawn" (`SEC7-7`),
while Step 0's `OQ-14` row still says "Rollback keeps its confirm step
regardless" and the `PL-12` table says "either way". This is the defect class the
last five rounds have returned, and it is load-bearing here: the create is
**irreversible** — the contract has no delete call — so `OQ-14` is being carried
open on a compensating control the plan itself says does not exist.

**Marked `Falsified: short`.** The falsifier's blind pick was wrong, but it
reported `answerable: yes` on a construction tell. It is asked under the degraded
rule, not as a clean survivor.

## Notes

- `stage: review`, `attempt: 16` — strictly above every retired
  `comprehension-review-*.md` attempt (highest retired: 15). `X5` holds.
- The previous record was retired to `comprehension-review-15.md` on entry
  (`§G E1`) before this stage ran.
- `evaluator.actor: owner` — answered by the ticket owner, not by an agent
  (`X6`).
