---
description: Author a TryDos backlog ticket (User Story / Acceptance Criteria / Test Cases) per the Backlog Ticket Standard and save it to .claude/_specs/<slug>.md. Pre-workflow step 1 — creates no workspace and no ticket.md state.
argument-hint: <feature description>
allowed-tools: Read, Glob, Write, AskUserQuestion
---

# /write-ticket

Write one backlog ticket for the feature described in `$ARGUMENTS`, following the
**TryDos Backlog Ticket Standard**, and save it to `.claude/_specs/<slug>.md`.

This is the ticket-authoring step (step 1 of the happy path) pulled out as a
command. It is **not** a workflow stage: it creates no `.claude/_specs/<slug>/`
workspace, no `ticket.md`, and advances no state. Bootstrapping the workspace is
still `/wf:start` (run it after this, with the ClickUp `<task_id>` if you
pushed the ticket).

Authoritative instructions (apply verbatim, do not restate):
- **How-to + TryDos context:** `.claude/docs/writing-tickets.md`
- **Canonical format** (metadata, 3-section body, common mistakes, quality
  checklist): `.claude/docs/backlog-ticket-standard.md`

## Steps

1. Read `CLAUDE.md` for the real modules/conventions, then read the two
   authoritative files above.
2. **Ask who the ticket is assigned to.** Use `AskUserQuestion` (header
   `Assignee`) before writing the file. Name the ticket in the question text,
   and ask one question per ticket when you author more than one, so each
   answer is unambiguous. Offer `Me (the person running this command)` first,
   `Unassigned` second, and any names already mentioned in the conversation or
   in `$ARGUMENTS` as the remaining options; the user types any other name
   through `Other`. Skip the question **only** when `$ARGUMENTS` already names
   an assignee explicitly. Record the answer in the ticket metadata as
   `Assignee`; for `Unassigned`, write `Assignee: ⚠️ TBD`.
3. Author the ticket per the Standard: required metadata (flag any genuinely
   unknowable field with `⚠️`), then exactly the 3 body sections in order
   (User Story → Acceptance Criteria → Test Cases), ending with the Ticket
   Quality Checklist. Keep tenant-safety criteria — TryDos is multi-tenant.
4. Save the full markdown to `.claude/_specs/<slug>.md` (kebab-case slug from
   the Title; create the dir if absent; disambiguate rather than overwrite a
   different existing ticket). Multiple tickets → one file each.
5. Report the file path and the assignee, then the next step: push to ClickUp
   (skill §5), then
   `/wf:start development <slug> "<Title>" clickup_id=<task_id>`
   (`development` is the workflow type — it is never chosen for the developer;
   there is no `mode` argument, the workflow has a single form, ADR-009).

## MUST NOT

- Do **not** create a `.claude/_specs/<slug>/` workspace or `ticket.md` (that is
  `/wf:start`).
- Do **not** push to ClickUp or touch git — authoring only.
