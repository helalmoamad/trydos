---
description: Author a Trydos backlog ticket (User Story / Acceptance Criteria / Test Cases) per the Backlog Ticket Standard and save it to .claude/tickets/<slug>.md. Pre-workflow step 1 — creates no workspace and no ticket.md state.
argument-hint: <feature description>
allowed-tools: Read, Glob, Write
---

# /write-ticket

Write one backlog ticket for the feature described in `$ARGUMENTS`, following the
**Trydos Backlog Ticket Standard**, and save it to `.claude/tickets/<slug>.md`.

This is the ticket-authoring step (step 1 of the happy path) pulled out as a
command. It is **not** a workflow stage: it creates no `.claude/_specs/<slug>/`
workspace, no `ticket.md`, and advances no state. Bootstrapping the workspace is
still `/start-ticket` (run it after this, with the ClickUp `<task_id>` if you
pushed the ticket).

Authoritative instructions (apply verbatim, do not restate):
- **How-to + Trydos context:** `.claude/skills/ticket-workflow/writing-tickets.md`
- **Canonical format** (metadata, 3-section body, common mistakes, quality
  checklist): `.claude/skills/ticket-workflow/references/Backlog Ticket Standard.md`

## Steps

1. Read `CLAUDE.md` for the real modules/conventions, then read the two
   authoritative files above.
2. Author the ticket per the Standard: required metadata (flag any genuinely
   unknowable field with `⚠️`), then exactly the 3 body sections in order
   (User Story → Acceptance Criteria → Test Cases), ending with the Ticket
   Quality Checklist. Keep the Session & Security Safety criteria — Trydos is a
   marketplace with chat/calls, so account/session scoping, seller-vs-buyer
   authorization, and localization (all four language bundles) are never optional.
3. Save the full markdown to `.claude/tickets/<slug>.md` (kebab-case slug from
   the Title; create the dir if absent; disambiguate rather than overwrite a
   different existing ticket). Multiple tickets → one file each.
4. Report the file path and the next step: push to ClickUp (skill §5), then
   `/start-ticket <slug> "<Title>" mode=<standard|high_risk> clickup_id=<task_id>`.

## MUST NOT

- Do **not** create a `.claude/_specs/<slug>/` workspace or `ticket.md` (that is
  `/start-ticket`).
- Do **not** push to ClickUp or touch git — authoring only.
