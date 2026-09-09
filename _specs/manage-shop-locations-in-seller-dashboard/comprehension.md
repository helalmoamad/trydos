---
ticket: manage-shop-locations-in-seller-dashboard
stage: verify
attempt: 3
status: complete
owner: developer
updated: 2026-09-06
result: passed
score: 2/2
threshold: 1.0
decision: PASSED
missed:
degraded: "2 of 3 — below the floor, administered short under CG-8 / ADR-028. Five falsification rounds were spent across this attempt and the two before it, and the per-question rewrite budget is exhausted. Of fourteen questions built, one cleared falsification outright and one is a final-round miss admitted by the degraded rule; the rest were rejected on a correct blind pick (several of which the falsifier itself called coin flips), on construction-tell, or because a stem leaked another question's answer. The CG-5 integration question WAS among the excluded: it was asked and answered correctly at attempt 2, and no replacement on that axis survived falsification at this attempt."
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Comprehension — manage-shop-locations-in-seller-dashboard

> The **verify** gate, attempt 3. Attempts 1 and 2 were retired to
> `comprehension-verify-1.md` and `comprehension-verify-2.md` on entry per §G/E1,
> so `attempt: 3` is strictly greater than every retired attempt for this stage
> (X5).

**Result: passed at 2/2 — 100% of what was asked, which is what `CG-4` requires of
a short gate.** The decision is recorded and the work item completes.

**Read the `degraded:` line before treating this as a full gate.** It was
administered at two questions against a floor of three, and the integration
question is among the excluded at *this* attempt — though the owner did answer one
correctly at attempt 2. That is recorded rather than smoothed over.

## Falsification record (CG-8)

Five rounds across the three attempts, questions and options only, no artifacts
attached, and the falsifier was never told which option was correct.

| Attempt | Rounds | Built | Cleared | Why the rest died |
|---------|--------|-------|---------|-------------------|
| 1 | 1 | 4 | 3 | One `construction-tell`: only one option paired two calls a *form* would own. |
| 2 | 3 | 8 | 1 | Three correct blind picks the falsifier itself called coin flips; two `construction-tell` (`AC-35` as the highest clustered id; "shared" as the only word signalling another screen); one stem that leaked another question's answer in the same set. |
| 3 | 2 | 6 | 1 | Two correct blind picks; two `answerable: yes` on engineering convention; one stem whose own contrast gave the answer away. |

**Why the set would not fill, stated honestly.** Most rejections were not real
tells. With four options, a fact the falsifier genuinely cannot derive is still
picked correctly about a quarter of the time, and the rule rejects on the pick
whatever the reasoning was. That killed six otherwise sound questions. The
remaining rejections were mine: three stems carried their own answer in the
wording, and one leaked from a neighbouring question.

**Administered short (CG-8, ADR-028).** The rounds are spent, so the gate asked the
last full round's **misses** — the display cap, which cleared falsification
outright, and the edit-control condition, whose blind pick was wrong though the
falsifier claimed it was answerable. Padding the set with questions the falsifier
had answered would have been worse than asking two.

## Review gate

<!-- Not this stage. The review gate's record is comprehension-review-18.md. -->

## Verify gate

| # | Question (from the artifact) | Source (implement.md/AC-n/plan §) | Axis | Hops | Options (correct + distractors) | Falsified (CG-8) | Owner's answer | Correct? |
|---|------------------------------|-----------------------------------|------|------|---------------------------------|------------------|----------------|----------|
| 1 | What is the length cap applied to backend text in read-only rendering on this screen? | `verify.md > AC-29`; `display_text_sanitizer.dart`; `spec.md > AC-29` | rendering / untrusted input | 2 | **200 characters** / 255 characters / 500 characters / No cap | yes | 200 characters | **Yes** |
| 2 | Besides holding the update permission, what second condition must be true before a row's edit control is shown? | `verify.md > AC-20`; `spec.md > AC-20`; `plan.md > Step 11` | permission / id safety | 2 | Country present / **Id positive int** / Status active / No write in flight | short | Id positive int | **Yes** |

Both questions are two-hop, which meets `CG-2(d)` for a set of two. Question 1's
distractor `255` is the name limit the same feature enforces, and question 2's
`No write in flight` is a real rule on the *status* control rather than the edit
one — minimally perturbed facts, not invented ones.

**What the two together establish.** The owner can state what this screen does to
untrusted backend text before drawing it, and what stops an unusable id ever
becoming a URL path segment. Those are the two places where a hostile or malformed
record reaches the app, and they were answered without the artifact open.

**What this gate did not establish**, and it is the reason `degraded:` is not
empty: nothing on the integration axis was asked at this attempt, so the owner's
understanding of what the change touches outside itself rests on attempt 2's single
correct answer, not on this record.

- Score (optional, only if `comprehension_gates.ai_graded`): n/a
