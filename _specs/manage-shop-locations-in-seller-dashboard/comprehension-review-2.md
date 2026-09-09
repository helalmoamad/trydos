---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
attempt: 2
status: complete
owner: developer
updated: 2026-08-30
result: passed
score: 5/5
threshold: 1.0
decision: CHANGES_REQUESTED
missed:
evaluator:
  host: claude
  actor: owner
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Comprehension — manage-shop-locations-in-seller-dashboard

> Single-owner gate control (ADR-009 / ADR-012 / CG-1..CG-7). The owner answered
> multiple-choice questions generated from `plan.md`, `spec.md`, and the panel
> findings already written to `review.md > Panel Findings` (RP-4). Options are
> listed alphabetically so position carries no signal. The gate records a
> decision only at 100% (CG-4).
>
> **Round 2.** `attempt: 2`, strictly above the retired `comprehension-review-1.md`
> (`attempt: 1`), as `rules/lifecycle-protocol.md` §G/X5 requires.
>
> Five questions were asked: the floor is three, and the panel returned **nine**
> `major` findings, which under CG-6 would add nine. The ceiling is five, so the
> mandatory integration question (CG-5) was kept and the remaining four were
> spent on the findings with the largest blast radius. Every `major` is still
> dispositioned in `review.md` — the ceiling caps questions, not accountability.
>
> Two of the nine majors were raised independently by two lenses each
> (`SR-5`/`SEC-1` and `SR-1`/`SEC-4`); each is treated as one finding here.

## Review gate

| # | Question (from the artifact) | Source (plan §/AC-n/panel:lens) | Axis | Options (correct + distractors) | Owner's answer | Correct? |
|---|------------------------------|---------------------------------|------|---------------------------------|----------------|----------|
| 1 | The plan adds the `extraHeaders` merge to `put.dart`, "the shared PUT client used by every feature". What did the panel find about the other HTTP clients, and what does it mean for AC-23? | `plan.md > Integration surface`; panel:senior + panel:security (major, `SR-5`/`SEC-1`) | **integration / cross-flow (CG-5)** | All four already honour it · **Every client but `post` drops it** (correct — only `post.dart` honours `extraHeaders`; `get`, `put`, `patch`, `delete` accept the field and silently discard it, so the list read carries no shop id and an `OQ-6` PATCH/DELETE status call would compile and do nothing) · Only `get.dart` drops it · The merge leaks globally | Every client but post drops it | Yes |
| 2 | Revision 2 moved the country picker onto `lib/common/constant/countries.dart` to escape the dropdown's prefs side effect. What did the senior lens find wrong with that choice? | panel:senior (major, `SR-3`); plan Step 10, `OQ-4` row; spec AC-4, AC-26 | correctness of a plan decision | It is empty until splash · **It is the phone dial-code table** (correct — entries carry `dialCode`, `minLength`, `maxLength` and an English-only `name`, so AC-4 + AC-26 cannot be met, and it offers ~250 countries the marketplace does not serve) · It lists only served countries · It writes prefs like the dropdown | It is the phone dial-code table | Yes |
| 3 | Two lenses independently found that AC-24 ("no location data is written to device storage") is already false. Why? | panel:senior + panel:security (major, `SR-1`/`SEC-4`); spec AC-24, Non-Functional; plan Rollback | data at rest / criteria truth | `DashboardBloc` is hydrated · Equatable keeps old props · The country picker caches · **The shared request log** (correct — the shared clients call `saveRequestsData` on every request, writing url, headers, query, body and response into plaintext SharedPreferences, and it survives a restart; tokens are redacted, location names and addresses are not) | The shared request log | Yes |
| 4 | AC-15 says a save counts as successful only when the response body says so. Why can the model Step 2 chooses not satisfy that? | panel:senior (major, `SR-2`); plan Step 2; spec AC-15 | correctness of acceptance criteria | Backend returns 204 empty · **Model has no success flag** (correct — `ReadOnlyMessageFromApiModel` carries only `message` and `response`, while `PutClient`/`PostClient` decide success purely from `statusCode == 200 \|\| 201`) · Model is generated, sealed · Response body is redacted | Model has no success flag | Yes |
| 5 | The security lens says AC-29 cannot be met by sanitising inside the form widget. What is the reason? | panel:security (major, `SEC-2`); spec AC-29; plan Step 10 | tenant / display safety | Backend blocks hostile text · Form never shows the message · **Shared toast shows it first** (correct — the shared POST client and interceptor display the raw backend `message` as a global toast with `showInRelease: true` before the screen sees it, with no cap and no direction-character stripping; the member also gets two messages for one refusal) · Translation layer escapes it | Shared toast shows it first | Yes |

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

## Verify gate

> Not applicable to this record. The verify gate earns its own
> `comprehension.md` with `stage: verify`, after this record is retired to
> `comprehension-review-2.md` on the next entry into a gated stage
> (`rules/lifecycle-protocol.md` §G/E1).
