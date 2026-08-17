---
ticket: refresh-token-stories-server
stage: review           # the gate that last updated this record
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | complete
owner: developer        # the ticket owner (self-review)
updated: 2026-08-16
result: failed          # quiz outcome — were ALL answers correct? (CG-4)
score: 3/4              # correct / total answered in the latest attempt (attempt 2; stopped at the first wrong answer)
decision: none          # gate decision; `none` when the quiz failed (ADR-011)
missed: Q1 (integration)  # the missed questions + axis, latest attempt
links:
  clickup:
  github:
---

# Comprehension — refresh-token-stories-server

> Single-owner gate control (ADR-009 / ADR-012 / CG-1..CG-7). At each gate the
> owner answers multiple-choice questions (**≥4 options each**) generated **from
> the artifact under review**. One section per gate — never overwrite another
> gate's section. The gate records its decision **only if 100% of answers are
> correct** (CG-4); any wrong answer blocks it. Each question's options are listed
> **alphabetically** — the correct answer's position must carry no signal.
>
> **English only.** Questions, options, answers, and every other word in this file
> are written in English — whatever language the conversation used (CLAUDE.md).
>
> **Three rows is the floor, not the form** (CG-1): add rows freely. Every gate
> carries **≥1 integration / cross-flow question** (CG-5), and `/review` adds
> **one row per `major` panel finding** on top of the floor (CG-6).
>
> **On a failed gate this file must not become an answer key (CG-7).** When
> `result: failed`, write the **Failed attempt** form below instead of the full
> table: the question, the axis, the answer the owner gave, and the artifact
> section to re-read. Do **not** write the option list and do **not** mark which
> option was correct. The gate is re-run, so an answer key stored next to the
> questions turns the re-run into a lookup — and this file is published with the
> ticket (PB-9). The full table with the marked correct answer is written **only**
> when `result: passed`, where CG-2 requires it and no re-run follows.
>
> **A re-run asks new questions (CG-7).** Replaying the same questions tests
> memory, not comprehension. Generate them again from the artifact; keep the same
> axes (including the mandatory integration axis), change the questions.

## Review gate

> Questions derived from `plan.md` + `spec.md` (CG-2), incl. `plan.md >
> Integration surface` and the Step 1a panel findings. Answered before recording
> the `/review` decision.

**Attempt 1 — `result: failed`.** The gate planned 10 questions: the floor of 3
(one of them the mandatory integration question, CG-5) plus one per `major` panel
finding (7 distinct majors, CG-6). The attempt was stopped by the owner after the
first 4 questions were answered. Of those 4, one was wrong, so CG-4 fails the
gate on its own — the remaining 6 questions were never asked.

Failed attempt, **no answer key** (CG-7):

| # | Question (from the artifact) | Source | Axis | Owner's answer | Correct? | Re-read |
|---|------------------------------|--------|------|----------------|----------|---------|
| 2 | The plan gives a smaller rollback for the case where the problem shows up only in the interceptor. What is it? | `plan.md > Rollback` | rollback | Clear all stored tokens | No | `plan.md > Rollback` |

Not recorded here: the three questions answered correctly (integration, validation
profile, and panel finding M1). Listing them with their answers would act as an
answer key for a gate that is about to be re-run (CG-7). The next attempt asks new
questions on the same axes.

**Attempt 2 — `result: failed`.** New questions on the same axes (CG-7); none from
attempt 1 was repeated. The first round of 4 was answered, one wrong, so CG-4
fails the gate and the remaining 6 questions were not asked.

Failed attempt, **no answer key** (CG-7):

| # | Question (from the artifact) | Source | Axis | Owner's answer | Correct? | Re-read |
|---|------------------------------|--------|------|----------------|----------|---------|
| 1 | Which two existing flows set a stories access token but would store no refresh token, so they always take the "nothing stored" path? | `plan.md > Integration surface` (Overlapping flows) | integration (CG-5) | Market guest and OTP verify | No | `plan.md > Integration surface` |

Not recorded here: the three questions answered correctly in this attempt
(rollback, files to change, and panel finding M1). Same reason as attempt 1 —
the gate is re-run and this file ships with the ticket (PB-9).

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

## Verify gate

> Questions derived from `implement.md` + `spec.md` (CG-2), incl. whether the
> plan's declared Integration surface held. Answered before recording PASSED at
> `/verify`. No panel here (ADR-010) — CG-6 does not apply.
>
> **CG-7 applies here too:** on `result: failed` use the failed-attempt form (no
> option list, no marked correct answer), and ask new questions on the re-run.

_Not yet run._
