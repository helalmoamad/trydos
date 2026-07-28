---
ticket: become-a-seller-not-showing
stage: spec
mode: standard
status: complete
owner: developer
updated: 2026-07-18
links:
  clickup:
  github:
---

# Spec — become-a-seller-not-showing

> Define *what* must be true when done. **No implementation details, no file
> names, no code.**

## Feature Name

"Become a Seller" visibility for users without a shop

## Business Goal

Seller onboarding is the entry to the marketplace's supply side. Today the
"Become a Seller" action on the profile page is shown only to users who are
already attached to a shop, so the users the action was designed for — those
with no shop at all — have no route into seller onboarding from their profile.
Restoring visibility for that audience unblocks the acquisition funnel for new
sellers.

## User Story

> As a user without a shop, I want to see the "Become a Seller" option on my
> profile, so that I can start selling on Trydos.

## Functional Requirements

- **REQ-1** — A user whose shop list is empty (or absent) must be offered the
  "Become a Seller" action on the profile page once their permission
  information has been retrieved successfully.
- **REQ-2** — A user who owns a shop (is its master) must not be offered the
  action. This is existing behaviour and must be preserved.
- **REQ-3** — A user attached to a shop they do not own must continue to be
  offered the action, exactly as today. This ticket does not change that
  audience's experience.
- **REQ-4** — Activating the action must lead to the existing seller-onboarding
  experience, with the existing phone-verification precondition applied
  unchanged.
- **REQ-5** — While permission information is being retrieved, the profile page
  must continue to show its existing loading placeholder rather than the action
  or a gap.
- **REQ-6** — When permission information cannot be retrieved, the action
  remains hidden (fail-closed), as today. Visibility is granted only on a
  confirmed empty shop list, never on an unknown one.
- **REQ-7** — The rest of the profile page — the surrounding actions, their
  order, and spacing — must be unaffected.

## Non-Functional Requirements

- **NFR-1** — No additional network requests are introduced; visibility is
  derived from information the profile page already observes.
- **NFR-2** — No additional rebuilds of the profile page beyond those already
  triggered by permission-status changes.
- **NFR-3** — The action's existing label must render correctly in all four
  supported languages and in right-to-left layout.
- **NFR-4** — Static analysis and the project's lint rules pass with no new
  warnings.
- **NFR-5** — No change to persisted state, so an existing installation
  upgrading to this build behaves correctly without a data migration or
  reinstall.

## Constraints

- **CON-1** — The change must not alter authentication, session, or
  phone-verification behaviour, including the verification check performed when
  the action is activated.
- **CON-2** — The change must not alter how permission information is requested,
  parsed, or stored, and must not change the shape of any shared application
  state. Other screens consuming the same shop information must be unaffected.
- **CON-3** — Ticket mode is `standard`; no high-risk surface may be touched. If
  the solution turns out to require one, the ticket must be escalated before
  implementation rather than proceeding.
- **CON-4** — No new user-facing copy is introduced; the existing localized
  label is reused.

## Edge Cases

- **EC-1** — Shop list is empty versus absent/not yet populated: both represent
  "no shop" once retrieval has succeeded, and both must show the action.
- **EC-2** — Retrieval fails, or is skipped because no usable phone number is
  stored: the action stays hidden (REQ-6) and the page must not error.
- **EC-3** — A user attached to several shops, master of some but not others:
  the outcome is determined by existing behaviour and is explicitly not
  redefined here (see OQ-2).
- **EC-4** — A user who has already submitted a seller request that is still
  pending: treated as a user without a shop, so the action is shown (see OQ-3).
- **EC-5** — A user who becomes a shop owner while the profile page is open: the
  action must disappear once the refreshed permission information arrives, with
  no restart required.
- **EC-6** — A user with an unverified phone number: the action is visible, and
  activating it follows the existing verification path rather than opening
  onboarding.

## Open Questions

- **OQ-1** — Should the action ever be shown when permission retrieval fails
  (fail-open)? Specified as fail-closed (REQ-6) to match today's behaviour;
  revisit only if product disagrees.
- **OQ-2** — For a multi-shop user, should ownership be judged across all shops
  rather than one of them? Deliberately left unchanged; a change here is a
  separate ticket.
- **OQ-3** — Should a user with a pending seller request see a distinct
  affordance (e.g. "request under review") instead of "Become a Seller"?
  Out of scope here; worth a follow-up ticket.
- **OQ-4** — Is analytics expected on the newly visible action? None specified,
  so none is required.

## Acceptance Criteria Mapping

> Give each criterion a stable ID (AC-1, AC-2, …); `verify.md` references these.

| ID   | Acceptance criterion | Maps to requirement |
|------|----------------------|---------------------|
| AC-1 | A user with no shop, after successful permission retrieval, sees the "Become a Seller" action on the profile page. | REQ-1, EC-1 |
| AC-2 | A user who owns a shop does not see the action. | REQ-2 |
| AC-3 | A user attached to a shop they do not own still sees the action, unchanged from before. | REQ-3 |
| AC-4 | Activating the action opens the existing seller-onboarding experience for a phone-verified user, and follows the existing verification path for an unverified one. | REQ-4, EC-6 |
| AC-5 | While permission information is loading, the existing loading placeholder is shown — not the action, not a gap. | REQ-5 |
| AC-6 | When permission retrieval fails or is skipped, the action stays hidden and the page renders without error. | REQ-6, EC-2 |
| AC-7 | Every other action on the profile page is unchanged in presence, order, and spacing. | REQ-7 |
| AC-8 | Other screens that consume the same shop information behave exactly as before. | CON-2 |
| AC-9 | The action's label renders correctly in all four supported languages and in right-to-left layout. | NFR-3 |
| AC-10 | Static analysis passes with no new warnings. | NFR-4 |
| AC-11 | No high-risk surface is touched: authentication/session, money, persisted state shape, and application start-up ordering are all unchanged. | CON-1, CON-3, NFR-5 |
| AC-12 | An existing installation upgrading to this build shows correct visibility without reinstalling or clearing data. | NFR-5 |

## Out of Scope

- Redefining ownership for multi-shop users (OQ-2).
- A distinct affordance for users with a pending seller request (OQ-3).
- Any change to the seller-onboarding experience itself.
- Any change to phone verification or the OTP flow.
- Any change to how permission information is requested, parsed, or stored,
  including the skip-when-no-phone-number behaviour.
- Showing the action optimistically when permission retrieval fails (OQ-1).
- New analytics or telemetry (OQ-4).
- Any entry point to seller onboarding outside the profile page.
