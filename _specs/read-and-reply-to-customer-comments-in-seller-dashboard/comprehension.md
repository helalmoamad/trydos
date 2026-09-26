---
ticket: read-and-reply-to-customer-comments-in-seller-dashboard
stage: review
attempt: 1
status: complete
owner: developer
updated: 2026-09-09
result: passed
score: 2/2
threshold: 1.0
decision: APPROVED
missed:
degraded: "2 of 3 — 3 questions could not clear CG-8 after both fact rounds and both option rewrites; the CG-5 integration question was among the excluded"
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5yctu"
  github:
---

# Comprehension — read-and-reply-to-customer-comments-in-seller-dashboard

## Review gate

> Questions derived from `plan.md` + `spec.md` and from `review.md > Panel
> Findings`, which were on disk before the gate ran (RP-4).

**Administered short under CG-8 (ADR-028).** Five questions were built and
falsified closed-book. Three were excluded because the falsifier's blind pick was
**correct**, and the regeneration budget — two fact rounds, plus two option
rewrites per question — was spent. The two below are the final round's questions
whose blind pick it got **wrong**, which is the at-chance evidence the check
exists to obtain. `CG-4`'s 100% applies to what was actually asked.

**The `CG-5` integration question was excluded.** Its final form asked which two
existing screens read the same live shop identifier, and the falsifier picked
`Shop Info and Locations` correctly from the word "shop" in the stem — a
construction tell that the fact itself cannot be separated from. Degraded mode is
the one place the integration axis may be dropped, and this record says so rather
than hiding it.

| # | Question (from the artifact) | Source (plan §/AC-n/panel:lens) | Axis | Hops | Options (correct + distractors) | Falsified (CG-8) | Owner's answer | Correct? |
|---|------------------------------|---------------------------------|------|------|---------------------------------|------------------|----------------|----------|
| 1 | A panel finding names the character cap that the helper `sanitizeForDisplay` applies to a display copy. What is that cap? | `panel:senior + security` (major, display truncation); `plan.md` step 11; `spec.md` `CON-5`, `AC-8` | correctness / untrusted input | 2 | 100 characters · 1000 characters · **200 characters** · 255 characters | yes | 200 characters | Yes |
| 2 | `spec.md` records what counts as acceptance evidence for every `AC-n` in this work item. What was decided? | `spec.md > Research Questions Resolved` `OQ-7`; `plan.md > Validation strategy` | evidence basis | 2 | A manual device run for every criterion, and code reading for the rest · A manual device run for every criterion, and the validation profile's static checks · Automated tests for the device-free units, and code reading for the rest · **Code reading for every criterion, and the validation profile's static checks** | short | Code reading, then static checks | Yes |

- Score: 2/2 (100% of what was asked — CG-4).

### Falsification log (CG-8)

| Round | Question | Blind pick | Correct? | `answerable` | Basis | Outcome |
|-------|----------|-----------|----------|--------------|-------|---------|
| 1 | Integration: which tabs are unaffected by the `props` change | c | **yes** | yes | domain-knowledge | rejected — `buildWhen` is the textbook mechanism |
| 1 | Which plan claim the interceptor finding contradicts | c | **yes** | yes | construction-tell | rejected — only one option could be contradicted |
| 1 | What Locations has that the plan lacks for `AC-4` | a | **yes** | yes | construction-tell | rejected — "clears" mapped onto the only `Clear…Event` |
| 1 | What `sanitizeForDisplay` breaks, and why | d | **yes** | yes | domain-knowledge | rejected — three options self-defeating |
| 1 | Which behaviour `_refreshLocationsAfterWrite` contradicts | d | **yes** | yes | domain-knowledge | rejected — refetch-resets-position is conventional |
| 2 | Integration: which two screens share the shop id | b | no | yes | construction-tell | option rewrite (free) |
| 2 | The two call-site counts (plan vs verified) | c | **yes** | no | domain-knowledge | rejected — correct by coin flip |
| 2 | Where each tab's page number lives | b | **yes** | yes | domain-knowledge | rejected — `meta` is the standard shape |
| 2 | The `sanitizeForDisplay` cap | 255 | no | **no** | domain-knowledge | **survives — `Falsified: yes`** |
| 2 | The acceptance evidence basis | c | no | yes | construction-tell | option rewrite (free) |
| 3 | Integration: which two screens share the shop id (rewritten) | d | **yes** | yes | construction-tell | rejected — "Shop" in the option matched the stem |
| 3 | The acceptance evidence basis (rewritten) | d | no | yes | construction-tell | second option rewrite (free) |
| 4 | The acceptance evidence basis (rewritten twice) | d | no | yes | domain-knowledge | **administered short — `Falsified: short`** |

**Budget spent:** two fact-change rounds (round 1 and round 2) and two option
rewrites for each question that earned them. No round was skipped and no question
was padded into the set.

## Verify gate

<!-- Not this stage. The verify gate writes its own record; entering it retires
     this file to comprehension-review-1.md per lifecycle-protocol §G/E1. -->
