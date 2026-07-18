---
ticket: become-a-seller-not-showing
stage: plan
mode: standard
status: complete
owner: developer
updated: 2026-07-18
links:
  clickup:
  github:
---

# Plan — become-a-seller-not-showing

> Decide the approach before changing code. Plan only — no implementation here.

## Approach

Restructure the visibility conditional in the profile page's seller-entry
`BlocBuilder` so that the gate is **ownership**, not **shop-list non-emptiness**.
Today an empty `shops` list fails the outer guard and falls through to the
trailing `SizedBox.shrink()`, hiding the action from exactly the users it targets
(research §Findings). The fix moves the non-empty check *inside* the ownership
test: render the action whenever permission retrieval succeeded and the user is
not a shop master, which makes "no shop" show the action (AC-1) while "owns a
shop" still hides it (AC-2) and "attached but not master" is unchanged (AC-3).

Chosen over the alternatives because it is the smallest correct change and keeps
the ticket in `standard` mode: adding a derived `canBecomeSeller` field to
`DashBoardState` would touch `**/*_state.dart`, a `high_risk_paths` glob, forcing
escalation (CON-3) for no behavioural gain; and changing the bloc to normalise a
null `shops` to `[]` would alter shared state consumed by the shop-selection
pages, breaching CON-2. Both are rejected. The change is confined to one widget
file and touches no auth, network, money, persisted-state, or start-up surface
(AC-11).

## Steps

1. Read the seller-entry `BlocBuilder` in the profile page and confirm the
   conditional still matches what research recorded (outer guard requires a
   non-empty `shops` list before anything but the shimmer can render).
2. Change the outer branch condition so it tests **only** that
   `getUserPermissionStatus` is `success`. Failure and `init` continue to fall to
   the existing trailing `SizedBox.shrink()`, preserving fail-closed behaviour
   (AC-6) — no new branch is introduced for them.
3. Move the shop-list non-emptiness check into the inner ownership condition, so
   the action is hidden only when the user has at least one shop **and** the
   first shop reports master. An empty or absent list therefore yields "not a
   master" and shows the action (AC-1, EC-1). Keep reading ownership from the
   first shop — multi-shop semantics are unchanged and out of scope (OQ-2).
4. Leave the `loading` shimmer branch, the `InkWell` body, its `onTap`
   phone-verification/OTP logic, the localized label, the icon, and the padding
   exactly as they are (AC-4, AC-5, AC-7, AC-9, CON-1, CON-4).
5. Add the shop list to the builder's `buildWhen` alongside the existing status
   comparison, so the action disappears without a restart when refreshed
   permission data arrives for a user who has just become an owner (EC-5). This
   stays inside the same widget and changes no shared state.
6. Run the validation profile's static analysis and confirm no new warnings
   (AC-10), including the repo lint rules that apply to the edited expression.
7. Manually exercise the three account shapes — no shop, shop owner, shop member
   who is not owner — plus the loading and retrieval-failure paths, and record
   the results as implementation evidence (AC-1, AC-2, AC-3, AC-5, AC-6).
8. Record files changed, any deviation from this plan, and the validation run in
   `implement.md`. Create no commit.

## Files to change

- `lib/features/home/presentation/pages/profile_page.dart` — the seller-entry
  `BlocBuilder` (the block rendering the "become a seller at trydos" action,
  around lines 322-403): invert the visibility gate from "has a non-empty shop
  list" to "is not a shop master", and extend `buildWhen` to also react to shop
  list changes. No other region of the file changes.

**No other file is to be modified.** In particular `dashBoard_bloc.dart`,
`dashBoard_state.dart`, `get_user_permission_model.dart`, the become-seller page,
and the shop-selection pages are all left untouched (CON-2, CON-3, AC-8). No
generated file is hand-edited and no localization bundle changes (CON-4).

## Validation strategy

- Validation profile: `flutter-standard`
- The profile's static-analysis check must pass with no new warnings, covering
  AC-10 and the lint constraints on the rewritten conditional.
- Manual device verification supplies the evidence for the behavioural criteria,
  since no automated test covers this screen (research §Risks): AC-1 (no shop →
  action visible), AC-2 (owner → hidden), AC-3 (non-owner member → visible,
  unchanged), AC-4 (activation opens onboarding when phone-verified, follows the
  verification path when not), AC-5 (shimmer while loading), AC-6 (retrieval
  failure → hidden, no error), AC-7 (surrounding profile actions unchanged).
- AC-8 is covered by inspecting the shop-selection screens after the change;
  since no shared state is modified, they are expected to be byte-for-byte
  unaffected — confirm by diff review that no file outside the one listed above
  was touched.
- AC-9 is covered by viewing the profile page in an RTL locale and confirming the
  existing label renders correctly in each of the four bundles.
- AC-11 is covered by diff review: no `high_risk_paths` glob is matched and no
  auth/session, money, persisted-state-shape, or start-up-order behaviour is
  altered.
- AC-12 is covered by installing the build over an existing installation without
  clearing data; visibility must be correct with no migration, which holds
  because no persisted state is touched.

## Rollback

- The change is a single self-contained edit to one widget file with no data,
  schema, API, or generated-code implications, so reverting the file to its
  previous revision fully restores prior behaviour with no cleanup, no migration,
  and no coordination with the backend.
- Because `/implement` creates no commit, an in-progress rollback is simply
  discarding the working-tree change to that one file; after delivery it is a
  revert of the delivery commit.
- No feature flag is warranted: the blast radius is one conditional on one
  screen, and the failure mode of a bad revert is cosmetic (the action shown or
  hidden to the wrong cohort), not data loss.

## Out of scope

- Redefining ownership for multi-shop users (`shops.first` semantics retained —
  OQ-2).
- A distinct affordance for users with a pending seller request (OQ-3).
- Showing the action optimistically when permission retrieval fails (OQ-1 —
  fail-closed retained).
- Any change to `DashboardBloc`, `DashBoardState`, the permission model, or the
  `myPhoneNumber.length < 3` short-circuit in the bloc.
- Any change to the become-seller onboarding experience, phone verification, or
  the OTP flow.
- New analytics or telemetry (OQ-4).
- New or changed localization keys, and any other entry point to seller
  onboarding outside the profile page.
- Adding automated test coverage for this screen (no harness exists for it;
  a separate ticket if wanted).
