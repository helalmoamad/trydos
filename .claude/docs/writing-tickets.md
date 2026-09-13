# Writing tickets — TryDos Backlog Ticket writer

Produce a backlog ticket that fully complies with the **TryDos Backlog Ticket Standard**.

> **The format is defined once, canonically, in
> [`backlog-ticket-standard.md`](./backlog-ticket-standard.md)** —
> required metadata, the status workflow, the exact 3-section body template
> (User Story → Acceptance Criteria → Test Cases), the "Common Mistakes to Avoid"
> rules, and the Ticket Quality Checklist. **Follow it verbatim; do not restate it
> here.** This file only adds the TryDos context and the operational how-to.

## Project context (TryDos)

TryDos is a **multi-tenant Go backend** (HTTP handlers → services → repositories, sqlc for
SQL, RabbitMQ for messaging, Firebase for push). Keep this in mind when writing criteria:

- **Tenant isolation is real and mandatory** — every data read/write must be scoped to the
  caller's tenant. Never let one tenant read or mutate another tenant's rows. The
  `Scope & Tenant Safety` section is never optional here.
- **API-first** — most work items are backend endpoints. Authorization failures return
  HTTP status codes (401/403); validation failures return structured JSON errors. If the
  feature has no UI surface, the `UI` half of "UI & API Consistency" may be N/A — say so
  explicitly rather than inventing UI behavior.
- **Backbone** is the module the ticket belongs to. Use a real TryDos module, e.g.:
  `Cart`, `Old Cart`, `Checklist`, `Notifications`, `Firebase Device Tokens`,
  `Mobile Home`, `Web Home`, `Auth`, `Guest Registration`. If a new module is implied,
  name it clearly.
- **Actors** in TryDos map to: `System Admin`, `Account Admin`, `Normal User`, `System`
  (e.g. a RabbitMQ consumer or scheduled job acting with no human actor).

## How to use

0. **First read the project summary / `CLAUDE.md`** so the ticket reflects the real modules,
   conventions, and constraints.
1. Take the feature the user describes (e.g. "add a cart overview totals endpoint").
2. Fill in **every required metadata field** (per the Standard). If a value is genuinely
   unknowable (Assignee, exact Sprint, Time Estimate), put a sensible placeholder/estimate
   and flag it with `⚠️` — a blank required field fails the standard.
3. Write the body with **exactly the 3 sections, in order** (per the Standard's template):
   User Story → Acceptance Criteria → Test Cases.
4. End with the **Ticket Quality Checklist** (from the Standard), ticking each box `[x]`
   only when the ticket genuinely satisfies it.
5. Output the whole ticket in one markdown block the user can paste straight into ClickUp.
6. **Always save the ticket to a markdown file** (see below) — every run ends by writing it.

## Always save to a markdown file

Every invocation MUST finish by writing the full ticket to a markdown file — do not stop at
showing it in chat. Rules:

- **Location:** `.claude/_specs/` at the repo root. Create the directory if it does not exist.
- **Filename:** a kebab-case slug derived from the ticket Title, e.g.
  `add-cart-overview-endpoint.md`. If a file with that name already exists and is a
  *different* ticket, append a short disambiguator rather than overwriting.
- **Contents:** the exact same markdown you output in chat — metadata table, the 3 body
  sections, and the Ticket Quality Checklist — nothing trimmed.
- **Multiple tickets in one run** (e.g. an epic split into children): write one file per
  ticket, and name them so the relationship is clear (e.g. `epic-<slug>.md` plus
  `<slug>-01-foundation.md`).
- After writing, tell the user the file path so they can open or paste it.
