# Trydos Backlog Ticket Standard

> **Purpose:** This is the official reference for writing tickets (User Stories / Work
> Items) in Trydos. Every team member must follow it. Any ticket that
> does not follow this standard is sent back to its author to be rewritten.

> **Language:** ticket bodies are written in **English**. Trydos is an Arabic-first,
> RTL product, but that belongs in the product, not the ticket — user-facing Arabic
> appears only as a quoted example or a localization key. Save as UTF-8.

## Required metadata (ClickUp Custom Fields)

Every one of these fields must be filled at the top of the ticket:

| Property | Type | Required | Description |
|---|---|---|---|
| **Title** | Text | ✔️ | Short title in the form: Verb + Object (e.g. "Create Order") |
| **ID** | Auto | ✔️ | Generated automatically |
| **Status** | Status | ✔️ | Official workflow (below) |
| **Backbone** | Select | ✔️ | The module (Authentication, Marketplace/Products, Cart & Checkout, Orders, Addresses, Comments & Reviews, Chat, Calls (Agora/CallKit), Stories, Search, Dashboard (Seller), Wallet/Payments, Notifications (FCM), Profile, Localization, Feedback…) |
| **Actor** | Multi-select | ✔️ | Buyer, Seller, System Admin, System |
| **Assignee** | Person | ✔️ | The responsible person |
| **Time Estimate (h)** | Number | ✔️ | Estimate in hours |
| **Sprint** | Relation | ⬜ | Linked sprint |
| **User Story Relation** | Relation | ⬜ | Link to the Epic |
| **Estimation per User Story** | Relation | ⬜ | Extra estimates (optional) |

### Status workflow

`Backlog` → `Planned` → `TODO` → `In progress` → `Ready For Developer Review` →
`Ready For EM Review` → `EM Testing (DEV ENV)` → `Ready For Release` →
`In Release (DEV_NEW)` → `Released To PROD`

(The release branch is `dev_new` — this repo has no `main`.)

## Body — exactly 3 sections, in this order

Copy this template as-is into the Description.

```markdown
## User Story

As **a [Actor / role]**,
I want to be able to **[action / capability]**,
so that **[business value / benefit]**.

[One short paragraph: scope, key constraints, what is in/out of scope,
references to related stories by ID.]

---

# Acceptance Criteria

## Session & Account Safety
1. [Atomic, testable statement — user accesses only their own account/session, orders, chats, and stories.]
2. [Atomic, testable statement — per-server tokens are never leaked or cross-used between backends.]

## Authorization
1. [Who may perform the action.]
2. Unauthorized attempts return 401/403 (API) / hide the control (UI).

## General Behavior
1. [What the feature does in general.]

## Form Fields

### Required Fields
1. **Field A**
2. **Field B**

Rules:
1. All required fields are validated before saving.

### Optional Fields
1. Field C
2. Field D

## Behavior After Saving
1. [What happens after a successful save.]

## Validation & Constraints
1. [Patterns, formats, mandatory-field enforcement.]

## UI & API Consistency
1. UI and API enforce identical rules.
2. Errors are returned in a structured format and surfaced in the UI.

## Localization & RTL
1. Every user-visible string is a localization key present in all four bundles
   (`en-US`, `ar-SY`, `ku-IQ`, `tr-TR`) — no hard-coded text.
2. The screen renders correctly in RTL (Arabic/Kurdish) and LTR.

## Audit & Logging
1. [What is logged on success.]
2. [What is logged on failure.]

---

# Test Cases

## Happy Path — [Descriptive scenario name]
**Given** [precondition]
**And** [extra precondition]
**When** [action]
**Then**
- [Expected, observable result]
- [Expected, observable result]

---

## Validation Error — [Descriptive scenario name]
**Given** [precondition]
**When** [invalid action / invalid input]
**Then**
- [Validation error is shown]
- [No data is saved]

---

## Authorization Failure — [Descriptive scenario name]
**Given** [unauthorized user / role]
**When** [they attempt the action]
**Then**
- [UI hides the control]
- [API returns 401/403]
```

> The **Ticket Quality Checklist** is added inside each Backlog ticket: Task → Add
> Checklist → Paste.

## Ticket Quality Checklist

- [ ] Title is short and action-oriented (verb + object)
- [ ] Status, Backbone, Actor, Assignee, Time Estimate are filled
- [ ] Body contains all 3 sections: User Story, Acceptance Criteria, Test Cases
- [ ] User Story uses As / I want / so that format with a real benefit
- [ ] Summary paragraph includes scope, constraints, in/out of scope
- [ ] Acceptance Criteria are grouped into named sub-sections
- [ ] Every criterion is atomic and testable (yes/no)
- [ ] Session & Account safety is explicitly addressed
- [ ] Authorization rules are clearly defined
- [ ] Validation rules are clearly defined
- [ ] Behavior After Saving is defined
- [ ] UI & API consistency is defined
- [ ] Localization (all four bundles) & RTL behavior is defined for any new copy
- [ ] Audit & Logging rules are included
- [ ] Test Cases cover: Happy Path, Validation Error, Authorization Failure
- [ ] No ambiguous words ("maybe", "etc.", "should probably")
- [ ] Related tickets referenced by ID (if applicable)

> This checklist lives in ClickUp Docs or Notion — not inside the ticket.

# Common Mistakes to Avoid When Writing Tickets

## 1. Bad Titles
- ❌ Using vague nouns like "Products", "Users", "Orders"
- ✔ Use action-oriented titles: "Create Order", "Edit Profile", "Publish Story"

## 2. Incorrect User Story Format
- ❌ Missing "so that…"
- ❌ Repeating the action instead of stating the benefit
- ✔ Must follow: As a…, I want…, so that…

## 3. Acceptance Criteria Problems
- ❌ Writing AC as one long paragraph
- ❌ No numbered lists
- ❌ No sub-sections
- ❌ Missing validation rules
- ❌ Missing authorization rules
- ✔ AC must be atomic, testable, grouped into sections

## 4. Missing Error/Validation Behavior
- ❌ Only describing the happy path
- ✔ Must include validation errors and authorization failures

## 5. Missing Test Cases
- ❌ No test cases at all
- ❌ Test cases not in Given/When/Then format
- ✔ Must include: Happy Path, Validation Error, Authorization Failure

## 6. Missing Required Metadata
- ❌ No Assignee
- ❌ No Time Estimate
- ❌ No Actor
- ❌ No Backbone
- ✔ All metadata must be filled before the ticket is accepted

## 7. Ambiguous Wording
- ❌ Using "maybe", "etc.", "should probably" (in any language)
- ✔ Replace with explicit, testable statements

## 8. No Reference to Related Tickets
- ❌ Not linking to parent Epic or related stories
- ✔ Always reference related tickets by ID
