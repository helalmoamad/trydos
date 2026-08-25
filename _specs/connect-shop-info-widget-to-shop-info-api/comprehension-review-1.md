---
ticket: connect-shop-info-widget-to-shop-info-api
stage: review
attempt: 1
status: complete
owner: developer
updated: 2026-08-24
result: passed
score: 5/5
threshold: 1.0
decision: CHANGES_REQUESTED
missed:
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xchm"
  github:
---

# Comprehension — connect-shop-info-widget-to-shop-info-api

> **This front matter is the gate record.** `rules/lifecycle-protocol.md` §G reads
> it: a gated stage may not be left unless `result: passed`, `score` meets
> `threshold`, and `stage` names the stage being left.
>
> `score` is written the human way (`5/5`) and read as a fraction; `threshold`
> is `1.0` because a gate passes only at 100% (CG-4). `attempt` counts the rounds
> of this stage's gate: no retired `comprehension-review-*.md` existed in the
> workspace, so this round is `1`.

> Single-owner gate control (ADR-009 / ADR-012 / CG-1..CG-7). Five questions were
> asked: the three-question floor (CG-1), one on the mandatory integration axis
> (CG-5), and extra rows for the `major` panel findings with the largest blast
> radius (CG-6). Six `major` findings were recorded and the ceiling is five
> questions, so one question covers two related findings and the remaining
> majors are dispositioned in `review.md` rather than examined — the ceiling caps
> questions, not accountability. Every option list is alphabetical, so position
> carries no signal.

## Review gate

Questions derived from `plan.md` + `spec.md`, including
`plan.md > Integration surface` and the panel findings already written to
`review.md > Panel Findings` before the first question was asked (RP-4).

| # | Question (from the artifact) | Source (plan §/AC-n/panel:lens) | Axis | Options (correct + distractors) | Owner's answer | Correct? |
|---|------------------------------|---------------------------------|------|---------------------------------|----------------|----------|
| 1 | If the new `@injectable` use cases are added but `sh gen.sh` is never run, what does the plan say happens? | `plan.md > Integration surface` (ordering / lockstep) | integration (CG-5) | **✔ Dependency injection cannot construct DashboardBloc, so the app fails at start, not at build** · A compile error names the missing use case · The dashboard endpoints start returning 404 at runtime · The three other language bundles ship untranslated labels | Dependency injection cannot construct DashboardBloc, so the app fails at start, not at build | Yes |
| 2 | Why can AC-6 and AC-9 (the permission gates) not be met by the plan as written? | panel:senior (major); `plan.md > Files to change`; AC-6, AC-9 | scope / feasibility | **✔ Case 7 builds `const ShopInfoWidget()` with no arguments and permissions are a DashboardContentPage constructor argument — yet the plan says that line is not touched** · AC-6 and AC-9 need a backend permission that does not exist yet · DashboardPermissionChecker has no `canSeeShopInfo()`, and the plan puts tab visibility out of scope · The permission enum is matched by ordinal, so appending values shifts the existing ones | Case 7 builds `const ShopInfoWidget()` with no arguments and permissions are a DashboardContentPage constructor argument — yet the plan says that line is not touched | Yes |
| 3 | Why can AC-23 ("the held profile is cleared and re-fetched") not be expressed with `DashBoardState.copyWith`, and what makes the obvious workaround dangerous? | panel:senior + panel:performance (two related majors, one question per CG-6); AC-13, AC-23 | blast radius | **✔ Every copyWith entry uses `x ?? this.x`, so a field can never be set back to null; emitting a fresh DashBoardState() would clear it but also discard every other tab's cached data** · copyWith is generated code and cannot be hand-edited · DashBoardState is hydrated, so clearing a field needs a migration path · The state is immutable, so the workaround is to mutate the bloc directly | Every copyWith entry uses `x ?? this.x`, so a field can never be set back to null; emitting a fresh DashBoardState() would clear it but also discard every other tab's cached data | Yes |
| 4 | What tenant-isolation hole did the security lens find that AC-22 and AC-23 do not close? | panel:security (major); AC-22, AC-23 | tenant safety | **✔ Because X-Seller-ID is resolved at request-build time from prefs, a shop switch between dispatching a save and the request being sent can write shop A's profile under shop B's id** · A member without UPDATE_SHOP_INFO can still reach the PUT · The permission list is shared between shops · X-Seller-ID is not sent on the PUT at all | Because X-Seller-ID is resolved at request-build time from prefs, a shop switch between dispatching a save and the request being sent can write shop A's profile under shop B's id | Yes |
| 5 | Which acceptance-criteria gap lets a save destroy a live logo and banner? | panel:security (major); AC-5, AC-17, AC-19; `plan.md > Rollback` | data loss | **✔ AC-19 validates only name, contact and address, so image and banner can be sent as null after a load that never delivered them** · AC-15 flattens image values to a bare file name · AC-17 sends an explicit empty value, which the backend rejects with a 422 · The upload can fail silently | AC-19 validates only name, contact and address, so image and banner can be sent as null after a load that never delivered them | Yes |

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

## Verify gate

*(not run — this record belongs to the `review` gate. The `verify` gate earns its
own record, and entering it retires this file to `comprehension-review-1.md`.)*
