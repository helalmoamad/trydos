---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
attempt: 12
status: complete
owner: developer
updated: 2026-08-31
result: passed
score: 2/2
threshold: 1.0
decision: CHANGES_REQUESTED
missed:
degraded: "2 of 3 — three questions could not clear CG-8 across three rounds; one of the two asked was admitted on a wrong blind pick despite answerable:yes; the CG-5 integration axis IS covered, by the shared-interceptor question"
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Comprehension — manage-shop-locations-in-seller-dashboard

> Attempt 12 of the `review` gate — round 8, the first gate on plan revision 8.
> Attempts 1-11 are retired as `comprehension-review-1.md` …
> `comprehension-review-11.md` and are never edited.
>
> **This attempt passed**, so CG-2's full record is written below with the option
> lists and the correct answers marked. No re-run follows.

## Review gate

> Questions derived from `plan.md` revision 8 + `spec.md` + the panel findings in
> `review.md > Panel Findings`, written before any question was asked (RP-4). All
> facts are new to this round — they come from findings the panel raised against
> revision 8, which did not exist when attempts 8-11 were built.

| # | Question (from the artifact) | Source (plan §/AC-n/panel:lens) | Axis | Hops | Options (correct + distractors) | Falsified (CG-8) | Owner's answer | Correct? |
|---|------------------------------|---------------------------------|------|------|---------------------------------|------------------|----------------|----------|
| 1 | The shared error interceptor shows the backend's message in a toast. For which responses does it fire? | `review.md > Panel Findings > SR8-1`; `plan.md > Steps 3a`; `spec.md > A-10` (`AC-14`, `AC-21`); `lib/core/api/log_interceptor.dart:92-105`; contract "Errors" | **integration (CG-5)** — app-wide shared interceptor this screen inherits behaviour from | 2 | **Only for 400 and 422** ✔ · For 400, 403 and 422 · For every 4xx and 5xx · For every failed request | yes | Only for 400 and 422 | **Yes** |
| 2 | Which wording about the country picker's item list appears in Step 10 of plan revision 8? | `review.md > Panel Findings > SR8-3`; `plan.md:577` vs `:621` and `:630`; round 7 follow-up 8 (`P7-4`) | plan-internal consistency | 2 | **Built once when the response arrives, and built once in `initState`** ✔ · Built once in `initState`, and rebuilt on every frame · Built once when the response arrives, and rebuilt in `itemBuilder` · Built once when the response arrives, and rebuilt on every status change | short | Built once when the response arrives, and built once in `initState` | **Yes** |

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

**Why question 2 has two "correct-looking" halves.** It does, and that is the
point: revision 8 added the corrected wording at `:577` **without deleting** the
two stale bullets at `:621` and `:630`. Both statements are in Step 10 today. The
question can only be answered by someone who has seen that, which is why it
survived falsification when the count-based version of it did not.

## Falsification record (CG-8, ADR-028)

Five questions were drafted, one per new `major` finding, and put through three
rounds.

| Round | Outcome |
|-------|---------|
| 1 | The falsifier's blind pick was **wrong on four of five** — but it called four of them `answerable: yes`. Only the interceptor question cleared outright. Tells: the correct option being the only mixed or only contradiction-shaped one, a two-option pair marking its differing axis as live, cross-question leakage between the status-code and toast questions, and one option that was both the longest and the only one explaining *why*. |
| 2 | Q1, Q3 and Q4 rebuilt as clean 2x2 grids on two independent repo facts each; Q5's fact replaced (the previous one fell to ordinary BLoC architecture). The status-code question was then answered **correctly** and dropped. The interceptor question cleared again. |
| 3 | Final round. Q1 and Q4 took their last permitted rewrite; Q5 changed fact again. **Q1 and Q5 were answered correctly and dropped.** Q4's blind pick was wrong. |

**Two questions survived, against a floor of three, so the gate was administered
short — not skipped.** The interceptor question cleared outright (`answerable:
no`, blind pick wrong in all three rounds it appeared). The Step 10 question was
admitted under the degraded rule, which takes a **miss** as at-chance evidence
"whatever it said under `answerable`"; its row is marked `short` — administered,
not cleared.

**The CG-5 integration question was asked, and cleared outright.** Unlike attempt
11, the integration axis is covered rather than excluded: the shared error
interceptor is app-wide infrastructure this screen inherits behaviour from, and
`SR8-1` is precisely a finding about what the screen assumed of it.

## The five gate rounds on this work item

| Attempt | Plan | Score | Result | Integration axis |
|---------|------|-------|--------|------------------|
| 8 | revision 7 | 0/1 | failed | could not be built |
| 9 | revision 7 | 1/3 | failed | asked — missed |
| 10 | revision 7 | 2/3 | failed | asked — correct |
| 11 | revision 7 | 3/3 | **passed** | excluded by the falsifier |
| 12 | **revision 8** | 2/2 | **passed** | **asked — correct** |

Attempt 12 is the first gate against revision 8, and the first where the panel
re-ran in full — attempts 9-11 reused round 7's findings because `plan.md` had not
changed between them.
