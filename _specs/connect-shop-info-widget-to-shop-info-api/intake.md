---
ticket: connect-shop-info-widget-to-shop-info-api
stage: intake
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-24
links:
  clickup: "https://app.clickup.com/t/z8n6b5xchm"
  github:
---

# Intake — connect-shop-info-widget-to-shop-info-api

> First stage. Qualify the request only. **No technical planning allowed.**

## Ticket Reference

- slug: `connect-shop-info-widget-to-shop-info-api`
- ClickUp task: `z8n6b5xchm` — https://app.clickup.com/t/z8n6b5xchm
  (TryDosProject → Backlog → Product Backlog List, status `draft`)
- Backlog ticket source of truth (authored before this workspace):
  `.claude/_specs/connect-shop-info-widget-to-shop-info-api.md`
- API contract: `.claude/docs/mobile-seller-dashboard-api-guide.md`, section
  **Shop Info**
- GitHub: none yet (set by `/wf:publish-pr`)

## Ticket Summary

`ShopInfoWidget` in the seller dashboard is still a mock: its three text fields
are seeded with hardcoded strings, the logo and banner are always empty, the two
picker methods are empty, and "Save Changes" only waits one second. The request
is to connect that widget to the two real endpoints in the API guide —
`GET {MARKET_API}/shop/info` to read the shop profile and
`PUT {MARKET_API}/shop/info` to save it — including the logo and banner upload.

## Ticket Metadata

- id / slug: `connect-shop-info-widget-to-shop-info-api`
- title: Connect Shop Info Widget To Shop Info API
- owner: developer
- created: 2026-08-24
- links: ClickUp `z8n6b5xchm`; no GitHub PR yet
- ClickUp fields set at push: Work Item Type `Story`, Priority `Medium`,
  Risk Level `Medium`, Time Estimate `16 h`, assignee Ali Fouaad
- Backbone `Seller Dashboard` and Actor are recorded in the ClickUp description
  only — the Product Backlog List has no custom field for either.

## User Story

> As a shop member inside my own shop (shop `OWNER`, or a team member holding the
> shop-info permissions), I want to see my shop's real name, contact number,
> address, logo and banner in the dashboard "Edit Shop Info" screen and save my
> changes, so that my public shop profile stays correct for buyers without asking
> support or using the website.

## Acceptance Criteria Presence Check

- Present? **yes**
- Notes: eight named groups in the backlog ticket — Scope & Tenant Safety,
  Authorization, General Behavior, Form Fields, Behavior After Saving,
  Validation & Constraints, UI & API Consistency, Audit & Logging. Every
  criterion is numbered and atomic. They are **not** yet AC-n ids; the `spec`
  stage assigns those.

## Test Cases Presence Check

- Present? **yes**
- Notes: ten Given/When/Then cases covering four happy paths, three validation
  errors, three authorization failures, and one tenant-safety case (switching
  shops). No case yet asserts an observable log line for the Audit & Logging
  criteria — the `spec` stage decides whether that gap matters.

## Workflow Type Check

Confirm this is a Development work item and not another workflow type. This is the
only type that cuts a branch and edits source files, so a wrong answer here costs
the most:

- Is the goal to *understand* something that already exists? **no** — the widget
  and the endpoints are both already understood and documented.
- Is the goal to *choose between options*? **no** — the API guide names the two
  endpoints, the request shape, and the upload folder. Nothing is being compared.
- Is the change to make already known, leaving only building it? **yes** —
  replace the mock with real calls through the existing dashboard layers.

**How the type was resolved** (CU-7):

| | |
|---|---|
| Resolved type | `development` |
| Source | `argument` |
| ClickUp field said | `—` (seed returned `workflow_type: null` and no raw value; the Product Backlog List has no workflow-type custom field) |
| Argument said | `development` |

The two do not disagree — the ClickUp side simply holds nothing. The argument is
the only source.

## Missing Information

Open questions carried into `research`. None of them blocks intake.

1. The API guide marks the backend's own validation rules for `/shop/info` as
   **not verified** — max lengths, the real phone format, and whether `image` may
   be `null`. The guide says to ask **Mohamad Hassan**.
2. Does the app already have one authoritative source for the currently selected
   `sellerId` (a shop switcher or an equivalent)? Several acceptance criteria
   depend on it, and the guide builds the switcher from
   `GET /shop/auth/permissions`.
3. Is the gated media upload flow (`POST {MEDIA}/gated/ticket` then
   `/gated/upload`) already used anywhere in the app, or is the existing
   presigned-URL path the only upload route today?
4. Where do the permission list and its loaded/failed state live in the app now?
   The "skip the GET when the permission says no, send it when the permission is
   unknown" rule needs those three states to be distinguishable.
5. No ClickUp Epic id exists yet for the Seller Dashboard parent epic, so
   `User Story Relation` is empty.

## Readiness Status

`READY`

- Justification: the request names one screen, one API section, and two
  endpoints. Acceptance criteria and test cases both exist and are written
  against a published contract. The five open items above are questions for
  `research` to answer inside the repository or to raise with the named backend
  owner — none of them changes what "done" means, and none prevents read-only
  investigation from starting.
