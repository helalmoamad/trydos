---
ticket: edit-phone-number-not-kept
title: Tapping the edit-pen on the verification-method screen returns to an empty phone field
workflow:
  type: hotfix
  version: 2
  current_stage: intake
  capabilities: []
status: active
owner: developer
created_at: 2026-09-08
updated_at: 2026-09-08
links:
  clickup: "z8n6b5x09d"
  github: ""
---

# Ticket Record — edit-phone-number-not-kept

> This file owns the ticket's lifecycle position in one field:
> `workflow.current_stage`. Stage artifacts never own workflow state.
> Do not hand-edit `workflow.current_stage` or `status` outside a transition.

## Workflow type

`hotfix`, given as the first argument to `/wf:start`. The argument is explicit, so
it wins and is never re-proposed. The ClickUp field could not be read (see
`intake.md` > Workflow Type Check), so there is no second value to compare it
against.

The `hotfix` lifecycle is `intake → diagnose → patch → verify`. Entry is not
granted by this label: the `intake` stage must first record a reproduction, the
wrong behaviour, and a **sourced** expectation. Until those three exist the work
item stays at `intake`.

## ClickUp

`clickup_id=z8n6b5x09d` was passed. The read-only seed failed:

```
CU-2 ERROR: ClickUp task 'z8n6b5x09d' fetch failed: HTTP 401
```

The title above therefore comes from the start argument, not from ClickUp. The id
is kept here as a reference. It is not a workflow input.

## State History

```yaml
- from_stage: null
  to_stage: intake
  event: ticket-created
  result: passed
  by: developer
  timestamp: 2026-09-08
```
