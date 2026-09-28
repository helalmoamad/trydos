---
ticket: manage-shop-locations-in-seller-dashboard
stage: review
attempt: 3
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
> **Round 3.** `attempt: 3`, strictly above the retired
> `comprehension-review-1.md` (`attempt: 1`) and `comprehension-review-2.md`
> (`attempt: 2`), as `rules/lifecycle-protocol.md` §G/X5 requires.
>
> Five questions were asked: the floor is three, and the panel returned **five**
> `major` findings after the gate runner's own re-check, so CG-6 adds exactly
> five — which meets the ceiling without needing to combine any of them. The
> mandatory integration question (CG-5) is question 1, which is itself sourced
> from a `major` about `plan.md > Integration surface`.
>
> One major (`SEC3-1`) was raised independently by all three lenses. Three
> findings the security lens filed as `major` were **downgraded to `minor` by the
> gate runner** after checking the navigation shape against the code; they are
> recorded in `review.md` with the reason, and were not used to seed questions.

## Review gate

| # | Question (from the artifact) | Source (plan §/AC-n/panel:lens) | Axis | Options (correct + distractors) | Owner's answer | Correct? |
|---|------------------------------|---------------------------------|------|---------------------------------|----------------|----------|
| 1 | What did the senior lens find about who actually reads `DashBoardState`, and why does it matter? | `plan.md > Integration surface`; panel:senior (major, `SR3-1`) | **integration / cross-flow (CG-5)** | It is hydrated to disk · Only the eleven dashboard tabs · **Read outside the dashboard too** (correct — `become_seller_page.dart` holds a `BlocListener` with no `listenWhen`, and `profile_page.dart` builds from the same state, so a bad `copyWith`/`props` change breaks seller registration and the profile page) · The orders tab rebuild storm | Read outside the dashboard too | Yes |
| 2 | All three lenses flagged Step 9's report channel. What is actually wrong with it? | panel:security + performance + senior (major, `SEC3-1`); plan Step 9; spec `AC-27` | secrets / data exposure | It POSTs auth tokens to backend (correct — the payload carries `userMarketToken`, `userChatToken`, `userStoriesToken`, `userWalletToken`, `userMarketPhone` and `lastApiRequest`, JSON-encoded and sent to the backend, so `AC-27` cannot be met; and the interceptor already fires the same event, so it double-sends) · It drops the shop id · It only runs in debug builds · It writes to device storage | It POSTs auth tokens to backend | Yes |
| 3 | The `AC-4`/`AC-26` amendment said the backend returns country names under the request's `lang` header. Why is that only half true? | panel:senior (major, `SR3-3`); spec `AC-4`/`AC-26` amendment; plan Step 10 | correctness of a spec amendment | **HomeBloc is a HydratedBloc** (correct — `getAllowedCountriesModel` is persisted to disk and refetched only at splash or on a failure retry, so names stay frozen in the language of the last fetch until the next app start) · It is unreachable from dashboard · The endpoint ignores lang · The names are ISO codes | HomeBloc is a HydratedBloc | Yes |
| 4 | Why does a free country picker create a risk, given the become-seller flow writes the same three location values? | panel:senior (major, `SR3-2`); plan Step 10; `OQ-11`, `OQ-6` | cross-flow correctness | **Become-seller never lets you choose** (correct — it sets `locationCountryIso` from prefs, the open market country, and bounds its map to that country; if the two are one record this screen could create locations in a country the rest of the system never produces, with possibly no way to delete them) · It offers unserved countries · The picker writes prefs · The two forms cap names differently | Become-seller never lets you choose | Yes |
| 5 | What is wrong with where revision 3 puts the `AC-29` sanitize helper? | panel:performance (major, `P3-2`); plan Steps 10, 11 | hot path / rendering cost | It duplicates the interceptor · It is applied only in the form · **It runs per row on the scroll path** (correct — applied per row inside `itemBuilder`, so every visible row on every frame gets a string scan and a fresh allocation, plus a compiled pattern per row if the `RegExp` is built per call) · It strips the country names | It runs per row on the scroll path | Yes |

- Score (optional, only if `comprehension_gates.ai_graded`): n/a

## Verify gate

> Not applicable to this record. The verify gate earns its own
> `comprehension.md` with `stage: verify`, after this record is retired to
> `comprehension-review-3.md` on the next entry into a gated stage
> (`rules/lifecycle-protocol.md` §G/E1).
