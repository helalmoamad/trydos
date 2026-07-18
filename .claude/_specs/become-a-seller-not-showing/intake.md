---
ticket: become-a-seller-not-showing
stage: intake
mode: standard
status: in_progress
owner: developer
updated: 2026-07-18
links:
  clickup:
  github:
---

# Intake — become-a-seller-not-showing

> First stage. Qualify the request only. **No technical planning allowed.**

## Ticket Reference

become-a-seller-not-showing — no ClickUp task / GitHub issue linked yet.

## Ticket Summary

Users who do not yet have a shop are not being offered the "Become a Seller"
entry point, so they have no way to start the seller onboarding flow. The ticket
is to make that entry point appear for users without a shop.

## Ticket Metadata

- id / slug: become-a-seller-not-showing
- title: Fix "Become a Seller" Not Showing for Users Without a Shop
- owner: developer
- created: 2026-07-18
- links: (none)

## User Story

> As a user without a shop, I want to see the "Become a Seller" option, so that
> I can start selling on Trydos.

## Acceptance Criteria Presence Check

- Present? yes (outline — to be formalised with stable `AC-n` IDs at `/spec`)
- Notes:
  - A user with **no shop** sees the "Become a Seller" entry point on the
    profile page.
  - A user who **owns** a shop (`isMaster`) does not see it (unchanged).
  - The loading/shimmer and error/empty presentation of the surrounding block
    is unchanged.

## Test Cases Presence Check

- Present? no (outline only)
- Notes: Manual scenarios per account type (no shop / shop owner / shop
  non-owner). To be written properly at `/spec`.

## Clarifications Received

- **Entry point location:** the profile page —
  `lib/features/home/presentation/pages/profile_page.dart` (the
  `DashboardBloc` / `getUserPermissionStatus` block that renders the
  "become a seller at trydos" action).
- **Gating variable:** `isMaster`, read from the first entry of
  `state.shops` (`GetUserPermissionModel.isMaster`, mapped from `is_master`).
- **Hidden for all shop-less users:** yes — confirmed, not limited to a subset
  (role, country, language or account state).

## Missing Information

- Reproduction metadata (account used, app version, platform) — not supplied;
  not blocking, since the condition is reproducible by account shape alone.
- Whether this is a regression and when it last worked — unknown; not blocking.
- Expected behaviour for a user who is attached to a shop but is **not** its
  master (e.g. an employee): today the entry point is shown to them. To be
  confirmed at `/spec` whether that is intended.

## Readiness Status

`READY`

- Justification: The affected surface (profile page), the gating variable
  (`isMaster`), and the expected behaviour for shop-less users are all
  confirmed. The remaining gaps (repro metadata, regression history) are
  informational and do not block read-only research. The one open behavioural
  question (non-master shop members) is carried forward as an open question.
