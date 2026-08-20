---
description: Author a Trydos backlog ticket (User Story / Acceptance Criteria / Test Cases) per the Backlog Ticket Standard, save it to .claude/tickets/<slug>.md, and — only after the user approves — push it to ClickUp. Pre-workflow step 1 — creates no workspace and no ticket.md state.
argument-hint: <feature or bug description>
allowed-tools: Read, Glob, Write, Edit, Bash
---

# /write-ticket

Author one backlog ticket for what `$ARGUMENTS` describes, save it to
`.claude/tickets/<slug>.md`, then **ask the user to approve it** and push it to
ClickUp only if they say yes.

This is the ticket-authoring step (step 1 of the happy path). It is **not** a
workflow stage: it creates no `_specs/<slug>/` workspace, no `ticket.md`, and
advances no state. Bootstrapping the workspace stays `/wf:start-ticket`.

Authoritative instructions (apply, do not restate):
- **Canonical format** (metadata, the 3-section body, common mistakes, quality
  checklist): `.claude/docs/backlog-ticket-standard.md`
- **Trydos context + how-to:** `.claude/skills/ticket-workflow/writing-tickets.md`

Where those two disagree, the Trydos context wins — it is adapted to this
repository (`Session & Account Safety` rather than tenant safety, the
`Localization & RTL` criteria section, `Buyer`/`Seller` actors, `dev_new`).

**The live ClickUp list overrides both.** The standard's metadata table and
status workflow are out of date: the Backlog list has no `Backbone` and no
`Actor` field, and its statuses are `draft / refining / ready for sprint /
blocked / complete`. Never guess a field or status name — read them in Phase 2
Step 1.

---

## Phase 1 — author the markdown (no network, no approval needed)

1. Read `docs/trydos-codebase-guide.md` for the real modules and conventions,
   then the two authoritative files above.
2. Decide the **work item type** from the description — a defect ("difference
   between web and app", "not showing", "crash") is a `Bug`; new capability is a
   `Feature`/`Story`. This picks the target list in Phase 2.
3. Author the ticket per the Standard: the metadata table (flag a genuinely
   unknowable value with `⚠️`, never leave it blank), then exactly the three body
   sections in order — User Story → Acceptance Criteria → Test Cases — ending
   with the Ticket Quality Checklist. Keep `Session & Account Safety` and
   `Localization & RTL`: Trydos is a marketplace with chat/calls, so account and
   session scoping, seller-vs-buyer authorization, and all four language bundles
   are never optional.
4. Write the full markdown to `.claude/tickets/<slug>.md` — kebab-case slug from
   the Title, UTF-8, create the directory if absent. If that file exists and is a
   *different* ticket, add a short disambiguator instead of overwriting. Multiple
   tickets → one file each.
5. Show the user the file path and a short summary: Title, target list, work item
   type, and the acceptance-criteria count. Then **ask, in one question, whether
   to push it to ClickUp** — offering: push it, edit something first, or keep it
   local. Stop and wait. Never push unasked.

If the user only wanted the file, Phase 1 is the whole command. Report and stop.

---

## Phase 2 — push to ClickUp (only after an explicit "yes")

All HTTP lives in `.claude/scripts/clickup_push.py` (ADR-005 isolation; the same
pattern as the plugin's read-only intake helper). This command builds a payload
file and invokes the helper — it embeds no HTTP, no `curl`.

The helper resolves the token itself: `CLICKUP_API_TOKEN` from the environment
first, then from the repo-root `.env`. On this machine the environment copy is a
stale token that returns 401 and the `.env` copy is the working one, so a
`token from environment rejected` line on stderr is expected, not a failure.
Never print the token.

### Step 1 — read the live list schema (read-only)

```
python .claude/scripts/clickup_push.py --show-fields <list>
```

`<list>` is a key of `clickup.lists` in `.claude/project-config.yaml`
(`backlog`, `bugs`, `tech_debt`, `auth`, `chat`, `story`, `mob_app`,
`seller_dashboard`), `test` for the dry-run list, or a numeric list id. Default
target: `bugs` for a defect, otherwise `backlog`.

Use the returned `statuses` and `fields` as the only source of truth for names
and dropdown options. Known shape today:

| List | Statuses | Custom fields |
|---|---|---|
| `backlog` | `draft`, `refining`, `ready for sprint`, `blocked`, `complete` | Priority, Technical Notes, Sprint, Risk Level, Dependencies, Work Item Type, Questions, Time Estimate (h), Attachments, User Story Relation, Business Value |
| `bugs` | same as backlog | Actual Behavior, Expected Behavior, Steps to Reproduce, Work Item Type |
| `mob_app`, `test` | `to do`/`testing`, `in progress`, `complete` | none |

`Backbone` and `Actor` do not exist as ClickUp fields — they stay in the
markdown metadata table, and may be summarized into `Technical Notes`.

### Step 2 — write the payload

Write it to the session scratchpad (never into the repository), as JSON:

```json
{
  "list": "backlog",
  "name": "<Title — verb + object>",
  "status": "draft",
  "markdown": "<the 3-section body, exactly as saved to .claude/tickets/<slug>.md>",
  "time_estimate_hours": 4,
  "fields": {
    "Work Item Type": "Bug",
    "Priority": "Medium",
    "Risk Level": "Low",
    "Time Estimate (h)": 4,
    "Business Value": "<one line>",
    "Technical Notes": "Backbone: <module> | Actor: <Buyer/Seller/System>"
  }
}
```

Rules for the payload:
- Omit `status` if unsure — ClickUp then applies the list's own default.
- Only include names that Step 1 returned; a name that does not exist is skipped
  with a warning and its value is silently lost from ClickUp.
- `assignees` and `tags` default to `clickup.default_assignee` and
  `clickup.default_tag`; pass them only to override.
- `markdown` is the body sections, not the metadata table and not the checklist.

### Step 3 — dry run, then create

```
python .claude/scripts/clickup_push.py --payload <file.json> --dry-run
python .claude/scripts/clickup_push.py --payload <file.json>
```

The dry run resolves the token, list, custom fields, and duplicate check and
prints the exact request body without creating anything. Read its `warnings`
before the real call — if a field or option was skipped, fix the payload and
dry-run again rather than pushing a ticket with missing metadata.

Exit codes: `1` usage/config/payload, `2` auth, `3` API rejected, `4` a task with
that name already exists in the list (re-run with `--allow-duplicate` only if the
user confirms a second copy is wanted).

### Step 4 — record the id and report

On success the helper prints `{"id","url","name","list_id"}`. Write the task id
and URL into the ticket's metadata table in `.claude/tickets/<slug>.md`, so the
next step has them. Report the URL, any warnings, and the next step:

```
/wf:start-ticket <clickup_url>
```

---

## MUST NOT

- Do **not** push to ClickUp without an explicit approval in the current
  conversation. Approval for one ticket is not approval for the next.
- Do **not** create a `_specs/<slug>/` workspace or a `ticket.md` — that is
  `/wf:start-ticket`.
- Do **not** touch git, and do **not** modify source code.
- Do **not** embed HTTP or `curl` in this command; the helper owns the API calls.
- Do **not** print or log the ClickUp token, and never write it into a file that
  is committed.
- Do **not** change any other ClickUp task: the helper only ever creates one new
  task, and no status, comment, or update is issued against anything else.
- Do **not** invent a field, option, or status name — read them with
  `--show-fields`.
