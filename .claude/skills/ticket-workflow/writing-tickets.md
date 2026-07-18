# Writing tickets — Trydos Backlog Ticket writer

Produce a backlog ticket that fully complies with the **Trydos Backlog Ticket Standard**.

> **The format is defined once, canonically, in
> [`references/Backlog Ticket Standard.md`](references/Backlog%20Ticket%20Standard.md)** —
> required metadata, the status workflow, the exact 3-section body template
> (User Story → Acceptance Criteria → Test Cases), the "Common Mistakes to Avoid"
> rules, and the Ticket Quality Checklist. **Follow it verbatim; do not restate it
> here.** This file only adds the Trydos context and the operational how-to.

## Project context (Trydos)

Trydos is a **Flutter mobile app** combining a marketplace, real-time chat/calls
(Agora via webview + CallKit), and stories. Clean Architecture, feature-first:
Page/Widget → feature BLoC → UseCase → Repository interface → RepositoryImpl →
RemoteDatasource → GetClient/PostClient/… → dio. Keep this in mind when writing criteria:

- **Session & Account Safety is real and mandatory** — a user can only ever access
  their own account, orders, chats, and stories; per-server tokens are never leaked or
  cross-used between backends; every order/wallet action is authorized and scoped to
  the authenticated user. The `Session & Account Safety` section is **never optional**.
- **UI is primary** — Trydos is a mobile app whose screens consume several backends
  (market, chat, stories, wallet, media, elastic…). Keep "UI & API Consistency": UI and
  API enforce identical rules, and auth failures (401/403) are handled and surfaced
  clearly in the UI. State every screen's expected behavior rather than inventing it.
- **Multilingual & RTL by default** — the UI is Arabic-first and RTL-aware. Any
  user-visible string is a localization key present in **all four** bundles
  (`assets/languages/{en-US,ar-SY,ku-IQ,tr-TR}.json`; Kurdish layers on Arabic), then
  regenerated with `sh keys.sh`. Say so in the criteria whenever new copy is added.
- **Feature-local BLoCs are fine; app-wide ones are not casual** — Trydos legitimately
  runs many BLoCs (auth, chat, home, order, story, category, boutique, pre-caching).
  Adding a BLoC inside one feature slice is normal `standard` work. Registering a **new
  app-wide BLoC** in DI + `lib/service/service_provider.dart` (or changing an existing
  registration's lifetime) is `high_risk`.
- **Persisted state has a shape contract** — states saved by `hydrated_bloc` must still
  deserialize the payloads already on users' devices. If a ticket changes a persisted
  state's shape, say so explicitly and require a migration/rollback criterion.
- **Backbone** is the module the ticket belongs to. Use a real Trydos module, e.g.:
  `Authentication`, `Marketplace/Products`, `Cart & Checkout`, `Orders`, `Addresses`,
  `Comments & Reviews`, `Chat`, `Calls (Agora/CallKit)`, `Stories`, `Search`,
  `Dashboard (Seller)`, `Wallet/Payments`, `Notifications (FCM)`, `Profile`,
  `Localization`, `Feedback`. If a new module is implied, name it clearly.
- **Actors** in Trydos map to: `Buyer`, `Seller`, `System Admin`, `System`
  (e.g. an FCM push handler, the call notification service, or a scheduled job acting
  with no human actor).

### Language — tickets are written in English

Ticket bodies are written in **English**, even though the product's UI is Arabic-first
and RTL. This keeps tickets machine-checkable, keeps the ClickUp push path simple, and
matches how the team files work.

- Arabic belongs in the **product**, not in the ticket: user-facing strings appear in
  the ticket only as quoted examples or localization keys.
- Where a ticket concerns Arabic/Kurdish copy, reference the key
  (e.g. `sort_reviews_newest`) and note that all four bundles must carry it — do not
  paste long Arabic prose into the body.

## How to use

0. **First read the project summary / `CLAUDE.md`** so the ticket reflects the real modules,
   conventions, and constraints.
1. Take the feature the user describes (e.g. "add an order tracking screen").
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

- **Location:** `.claude/tickets/` at the repo root. Create the directory if it does not exist.
- **Filename:** a kebab-case ASCII slug derived from the ticket Title, e.g.
  `add-order-tracking-screen.md`. For an Arabic-titled ticket, transliterate or use the
  English equivalent of the title for the slug — the slug must stay filesystem-safe and
  is reused as the workflow ticket slug and branch name. If a file with that name already
  exists and is a *different* ticket, append a short disambiguator rather than overwriting.
- **Encoding:** UTF-8, so Arabic bodies survive intact.
- **Contents:** the exact same markdown you output in chat — metadata table, the 3 body
  sections, and the Ticket Quality Checklist — nothing trimmed.
- **Multiple tickets in one run** (e.g. an epic split into children): write one file per
  ticket, and name them so the relationship is clear (e.g. `epic-<slug>.md` plus
  `<slug>-01-foundation.md`).
- After writing, tell the user the file path so they can open or paste it.
