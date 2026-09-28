---
ticket: manage-shop-locations-in-seller-dashboard
stage: intake
mode: standard          # single workflow form — no other modes (ADR-009)
status: complete        # not_started | in_progress | blocked | complete
owner: developer
updated: 2026-08-27
links:
  clickup: "https://app.clickup.com/t/z8n6b5xkzd"
  github:
---

# Intake — manage-shop-locations-in-seller-dashboard

> First stage. Qualify the request only. **No technical planning allowed.**

## Ticket Reference

- slug: `manage-shop-locations-in-seller-dashboard`
- ClickUp task: `z8n6b5xkzd` — https://app.clickup.com/t/z8n6b5xkzd
  (TryDosProject → Backlog → Product Backlog List `901818662901`)
- Backlog ticket source of truth (authored before this workspace):
  `.claude/_specs/manage-shop-locations-in-seller-dashboard.md`
- Target code: `lib/features/dashBoard/presentation/pages/dashboard_page.dart`
  — `LocationsWidget` (line 3015), reached from tab index 8
- API contract: `.claude/docs/mobile-seller-dashboard-api-guide.md` — **there is
  no Locations section in it.** See Missing Information item 1.

## Ticket Summary

`LocationsWidget` in the seller dashboard is still a mock: it holds one hardcoded
`LocationModel` in a local list, and `_onAddLocation`, `_onEdit`, and
`_onDeactivate` are empty `TODO` bodies. The request is to connect that widget to
the real `{MARKET_API}` Locations endpoints so a shop member can see, add, edit,
and deactivate the shop's locations from the app, using the same layers and
permission gating the dashboard already uses for Shop Info and Gallery.

## Ticket Metadata

- id / slug: `manage-shop-locations-in-seller-dashboard`
- title: Manage Shop Locations in Seller Dashboard
- owner: developer
- created: 2026-08-27
- links: ClickUp `z8n6b5xkzd`; no GitHub PR yet
- ClickUp fields set at push: assignee Ali Fouaad only. The task was pushed
  **without metadata** at the developer's request, so Work Item Type, Priority,
  Risk Level, and Time Estimate are **not** set on the ClickUp task. The backlog
  ticket file carries Status `Backlog`, Backbone `Seller Dashboard`, Actor
  `Account Admin / Normal User`, and an estimate of ⚠️ 20 h.
- The Ticket Quality Checklist was also left off the ClickUp description — per
  the Backlog Ticket Standard it belongs in a ClickUp Checklist, not the body.

## User Story

> As a shop member with location permissions inside my own shop, I want to see,
> add, and edit my shop's locations from the Locations tab of the seller
> dashboard, so that my warehouses and pickup points are correct in the app and I
> no longer have to open the website to change them.

## Acceptance Criteria Presence Check

- Present? **yes**
- Notes: eight named groups in the backlog ticket — Scope & Tenant Safety,
  Authorization, General Behavior, Form Fields, Behavior After Saving,
  Validation & Constraints, UI & API Consistency, Audit & Logging. Every
  criterion is numbered and atomic. They are **not** yet AC-n ids; the `spec`
  stage assigns those. Several criteria carry an **[ASSUMED]** marker because the
  endpoint and permission names they name are not published anywhere — `spec`
  must resolve each of those before it fixes an AC-n against it.

## Test Cases Presence Check

- Present? **yes**
- Notes: ten Given/When/Then cases — four happy paths (list, add, edit,
  deactivate), two validation errors (empty name, backend 422), two
  authorization failures (no read permission, no create permission), one
  tenant-safety case (switching shops), and one error-handling case (paging
  fails with a list already on screen). No case yet asserts an observable log
  line for the Audit & Logging criteria; `spec` decides whether that gap matters.

## Workflow Type Check

Confirm this is a Development work item and not another workflow type. This is the
only type that cuts a branch and edits source files, so a wrong answer here costs
the most:

- Is the goal to *understand* something that already exists? **no** — the widget
  is already read and understood; the work is to replace its mock data with real
  calls.
- Is the goal to *choose between options*? **no** — nothing is being compared.
  The missing API contract (item 1 below) is a **fact to obtain from the backend
  owner**, not a choice between candidates, so it does not turn this into a
  `research` work item.
- Is the change to make already known, leaving only building it? **yes, at the
  app layer** — wire `LocationsWidget` through the existing dashboard layers
  (data source → repository → use case → BLoC → widget) and gate it with
  `DashboardPermissionChecker`. What is not yet known is the exact URL, field
  names, and permission strings — see Missing Information.

**How the type was resolved** (CU-7):

| | |
|---|---|
| Resolved type | `development` |
| Source | `argument` |
| ClickUp field said | `—` (seed returned `workflow_type: null` and `workflow_type_raw: null`; the Product Backlog List has no workflow-type custom field) |
| Argument said | `development` |

The two do not disagree — the ClickUp side simply holds nothing. The argument is
the only source.

> Note on the seed: `scripts/clickup_intake.py` first failed with **HTTP 401**
> because the token in the shell environment is stale. It succeeded when run with
> the `CLICKUP_API_TOKEN` from the project `.env`, and needs `PYTHONIOENCODING=utf-8`
> on this Windows console or it crashes printing the description.

## Missing Information

Open questions carried into `research`. None of them blocks intake.

1. **The Locations API contract does not exist in writing.**
   `.claude/docs/mobile-seller-dashboard-api-guide.md` has no Locations section,
   and its Shop Info section says the opposite — that "boutique banners and shop
   locations are all other screens/endpoints". The endpoints in the backlog
   ticket (`GET/POST/PUT {MARKET_API}/shop/locations` plus a status-change call)
   are **assumed**. Ask **Mohamad Hassan**, the owner of `{MARKET_API}`, then add
   the section to the API guide.
2. **The Locations permission names are unknown.** The guide's permissions table
   has no Locations row, and `DashBoardPermission` in
   `lib/features/dashBoard/presentation/widgets/permission_enum.dart` has no
   locations entry. `READ_LOCATIONS`, `CREATE_LOCATION`, `UPDATE_LOCATION`, and
   `CHANGE_LOCATION_STATUS` are guesses from the naming pattern of the existing
   `*_BUTIKS` and `*_SHOP_INFO` values. The real strings must come from
   `GET /shop/auth/permissions` on a shop that has them.
3. **Does the website already have a Locations screen?** If it does, its client
   code is the fastest way to learn the real contract, the same way the Shop Info
   and Excel sections of the guide were checked against the web client on
   `develop`.
4. **Where does the currently selected `sellerId` live?** Several criteria depend
   on one authoritative source for it, and on clearing the list when the shop
   changes. The sibling work item
   `_specs/connect-shop-info-widget-to-shop-info-api/` asked the same question —
   `research` should read its `research.md` before searching again.
5. **Is there already a country list or country picker in the app?** The form
   requires country to be picked from a list, not typed. If none exists, whether
   to add one is a real scope question for `spec`.
6. **Does the backend separate "deactivate" from "delete"?** The ticket scopes
   deactivate only. If the backend offers just a delete, the AC has to change.
7. **Which new `LocaleKeys` are needed?** The key `locations` already exists
   (`lib/generated/locale_keys.g.dart:930`). Every other string in the widget is
   hardcoded English today, so `research` should list what has to be added to all
   four locale files and regenerate with `keys.sh`.
8. No ClickUp Epic id exists yet for the Seller Dashboard parent epic, so
   `User Story Relation` is empty.

## Readiness Status

`READY`

- Justification: the request names one widget, one dashboard tab, and one set of
  operations, and both acceptance criteria and test cases exist. The missing API
  contract (items 1 and 2) is real and material — it changes endpoint paths,
  field names, and permission strings — but `research` is read-only and can make
  progress on all of it: read the sibling work item, map the layers Shop Info and
  Gallery already use, check the website for a Locations screen, and turn each
  unknown into a traceable `OQ-n`. Nothing is built against the assumed contract
  at this stage.
- **Condition carried forward:** `spec` must not fix an AC-n against an
  **[ASSUMED]** endpoint, field, or permission name. Every one of them has to be
  confirmed by Mohamad Hassan — or turned into an explicit, recorded assumption —
  before the plan is written. Decided by the developer at intake on 2026-08-27.
