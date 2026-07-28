---
name: ticket-workflow
description: Operating procedure for taking one unit of work from idea → ClickUp ticket → Engineering-Workflow-v1 stages (start-ticket/research/spec/plan/review/implement/verify) → GitHub PR in the Trydos Flutter app (marketplace + chat/calls + stories). Use when the user asks to write/create a backlog ticket, task, or user story (Trydos Backlog Ticket Standard — see writing-tickets.md), run the ticket workflow, drive the stages, push a ticket to ClickUp, pick standard vs high_risk mode, open the PR, or asks about this environment's gotchas (never hand-edit generated *.g.dart/*.config.dart — regenerate with gen.sh/keys.sh; hydrated BLoC state shape needs migration; keep all four assets/languages bundles in sync; ClickUp REST vs MCP; branch base = dev_new).
---

# Ticket Workflow Guide — trydos

A practical guide to taking one unit of work from **idea → ClickUp ticket →
Engineering-Workflow-v1 stages → GitHub PR** in the Trydos Flutter app
(marketplace + real-time chat/calls + stories; Clean Architecture, BLoC, dio,
get_it+injectable, dartz, go_router, easy_localization).

- **This file** = the single operating procedure (how-to-use + this environment's gotchas).
- **Canonical rules** (never overridden by this guide) =
  `.claude/project-config.yaml`, `.claude/rules/workflow-rules.md`,
  `.claude/rules/validation-model.md`.

> **Run it step-by-step.** Pause and ask for approval before each stage. On
> approval → proceed to the next step; on denial → the operator gives a comment,
> which you incorporate before re-presenting. Never chain stages without an
> approval in between — this applies especially to the review gates and to
> outward-facing actions (ClickUp task creation, git commit/push, opening a PR).

---

## 1. Pick the mode

All work runs the same seven stages; the mode only sets the depth.

| The change… | Mode |
|---|---|
| Normal feature/fix inside one feature slice, bounded blast radius | **standard** (1 approval) |
| Hits a high-risk trigger (below) | **high_risk** (1 approval + ADR + rollback rehearsal) |

**High-risk triggers** (canonical list: `project-config.yaml > high_risk_paths`
plus the cross-cutting rules under it):

- `lib/features/authentication/**`, prefs/token storage, per-server tokens
- `lib/core/api/**` or the `*_url_routes.dart` configs — including **adding or
  renaming a `ServerName`** or changing base-URI resolution
- composition root: `lib/main.dart` (its **ordered** init: hydrated storage →
  dotenv → DI → notifications → Sentry → runApp, and the FCM background-isolate
  guards), `lib/core/di/**`, `lib/base_page.dart`,
  `lib/service/service_provider.dart`, `lib/routes/**`
- **hydrated BLoC state shape** — any `*_state.dart` whose `*_state.g.dart` is
  persisted. Old payloads on a user's device must still deserialize.
- calls/push: `lib/features/calls/**`, the notification services
- money surfaces: wallet routes, order totals / payment widgets
- config & secrets: `.env`, `AndroidManifest.xml`, `Info.plist`, `assets/languages/**`
- generated code: `**/*.g.dart`, `**/*.config.dart`, `locale_keys.g.dart`

> **Not** a high-risk trigger by itself: adding a *feature-local* BLoC. Trydos
> legitimately runs many BLoCs. Only registering a **new app-wide BLoC** in DI +
> `ServiceProvider` (or changing an existing registration's lifetime) is high_risk.

---

## 2. The happy path (copy-paste)

```text
# 1. Create the ticket  (write it per writing-tickets.md → .claude/tickets/<slug>.md)
#    follow the Trydos Backlog Ticket Standard (see "Writing tickets" below)
#    push it to ClickUp via REST (see §4) → note the returned <task_id>

# 2. Bootstrap the workspace
/start-ticket <slug> "<Title>" mode=standard clickup_id=<task_id>
#    open .claude/_specs/<slug>/intake.md → set Readiness Status = READY

# 3. Author stages
/research <slug>          # read-only discovery → research.md
/spec <slug>              # AC-1..AC-n (no file names / no code) → spec.md
/plan <slug>              # approach, files, validation profile, rollback → plan.md

# 4. Review gate  (a human is the reviewer — NOT the AI author)
/review <slug> APPROVED "<rationale>"

# 5. Branch, then implement   (base is dev_new — this repo has NO `main`)
git pull --no-edit origin dev_new
git checkout -b ticket/<slug>
/implement <slug>         # edits only the planned files, leaves them uncommitted

# 6. Verify → closes the ticket
/verify <slug>            # runs the plan's validation profile; maps every AC → PASS closes it

# 7. Deliver to GitHub (manual — see §5)
git add <the ticket's files> && git diff --cached --name-status   # CONFIRM the set
git commit -m "feat(<area>): <summary>"
git push -u origin ticket/<slug>
#    open the compare URL, set base = dev_new, paste PR body → record the PR URL
```

---

## 2b. Writing tickets (step 1 detail)

The ticket written in step 1 must follow the **Trydos Backlog Ticket Standard**.
Full instructions — required metadata, the 3 body sections (User Story /
Acceptance Criteria / Test Cases), hard rules, and the quality checklist — are
defined canonically in
[Backlog Ticket Standard.md](references/Backlog%20Ticket%20Standard.md);
[`writing-tickets.md`](writing-tickets.md) adds the Trydos context and the how-to.
Every run saves the ticket to `.claude/tickets/<slug>.md`.

---

## 3. What each command does

State is owned by one file: `.claude/_specs/<slug>/ticket.md > state`.
Every command reads it, does its work, writes its artifact, and advances it.

`draft → ready-for-research → research-complete → spec-complete → plan-complete → approved → implementation-in-progress → implemented → verified → closed`

| Command | Produces | State after |
|---|---|---|
| `/start-ticket` | `ticket.md` + `intake.md` | `draft` |
| `/research` | `research.md` (read-only discovery) | `ready-for-research` |
| `/spec` | `spec.md` (requirements + `AC-n`) | `research-complete` |
| `/plan` | `plan.md` (approach, files, validation, rollback) | `spec-complete` |
| `/review APPROVED` | `review.md` | `approved` (REJECTED → `closed`) |
| `/implement` | branch + code edits (no commit) + `implement.md` | `implemented` |
| `/verify` | `verify.md`; PASS closes | `closed` (FAIL → blocked) |

After `/verify` closes the ticket, **delivery to GitHub is manual** (git by hand +
open the PR in the browser — see §5). It is not a command, not a gate, and changes
no workflow state.

### Validation profiles (named in `plan.md > Validation strategy`)

| Profile | Use when | Runs |
|---|---|---|
| `flutter-standard` | default | `flutter analyze` |
| `codegen-change` | models / `@injectable` / DI changed | `gen.sh` equivalent + no-diff, then analyze |
| `localization-change` | `assets/languages/*.json` or keys changed | bundle parity + `keys.sh` no-diff + analyze |
| `hydrated-state-change` | a persisted BLoC state shape changed | codegen no-diff + analyze + rollback rehearsal |

---

## 4. Push a ticket to ClickUp (REST, not MCP)

The ClickUp **MCP** server is license-locked for writes here, so use the REST API
with the token in the gitignored **`.claude/.env`** (`CLICKUP_API_TOKEN`, covered by
`.gitignore`'s `*.env`). The ids are already resolved in
`project-config.yaml > clickup` — workspace `Ramaaz Co` (90182710436), space
`TryDosProject` (901811062695), default list **Backlog / Product Backlog List**
(901818662901), plus per-area lists (auth, chat, story, MobApp, Seller DashBoard,
Bugs, Fixes & Technical Debt). Dry runs go to the `backtest` list (901818971923).

```powershell
$tok = ((Get-Content "d:\trrdos\trydos\tyrdos\trydos\.claude\.env" | Where-Object { $_ -match '^CLICKUP_API_TOKEN=' } | Select-Object -First 1) -replace '^CLICKUP_API_TOKEN=','' -replace '"','').Trim()
$raw = Get-Content "d:\trrdos\trydos\tyrdos\trydos\.claude\tickets\<slug>.md" -Raw -Encoding utf8
# Description starts at the User Story - drop the H1 title heading + Metadata table
# (Title is the task `name`; metadata belongs in ClickUp fields, not the body).
$body = $raw.Substring($raw.IndexOf("## User Story"))
# Dodge ClickUp's misleading 413 on non-ASCII glyphs:
$body = $body -replace [char]0x26A0,'(!)' -replace [char]0xFE0F,'' -replace [char]0x2014,'-' -replace [char]0x2192,'->'
$body = -join ($body.ToCharArray() | Where-Object { [int]$_ -lt 128 })
$payload = @{ name = "<Ticket Title>"; description = $body; assignees = @(<ASSIGNEE_ID>); tags = @("<TAG>") } | ConvertTo-Json -Depth 5
$resp = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/<LIST_ID>/task" -Method Post -Headers @{ Authorization = $tok } -ContentType "application/json" -Body $payload
"$($resp.id)  $($resp.url)"
```

> Ticket bodies are **English** (see the Backlog Ticket Standard), so the ASCII
> fold above is safe. If a ticket ever needs non-Latin text, drop that `-join`
> line and post UTF-8 — it would otherwise delete the body outright.

> **Two more ClickUp gotchas (learned the hard way):**
> 1. **Description body starts at `## User Story`.** Do **not** paste the ticket file's
>    H1 title + Metadata table into the description — the Title is the task `name`, and the
>    metadata (Backbone/Actor/Time Estimate/Work Item Type/Risk Level) belongs in ClickUp
>    fields. The `.Substring(IndexOf("## User Story"))` above strips them.
> 2. **Custom fields can't be set on this workspace's plan.** `POST .../task/<id>/field/<id>`
>    returns `{"err":"Custom field usages exceeded for your plan","ECODE":"FIELD_033"}`.
>    Don't waste calls trying — leave that metadata in the canonical ticket file
>    (`.claude/tickets/<slug>.md`) + the workflow's `ticket.md` (which is what the stages
>    actually read `mode` from). Only `name`, `description`, `assignees`, `tags`, and the
>    native task `status` are reliably writable via REST here.

To (re)discover lists:
```bash
TOK=$(grep -h '^CLICKUP_API_TOKEN=' .env | head -1 | cut -d= -f2- | tr -d '"'"'"' \r')
curl -s -H "Authorization: $TOK" "https://api.clickup.com/api/v2/space/<SPACE_ID>/folder?archived=false"
```
**Read a task back** (read-only, what `/start-ticket clickup_id=` uses):
`py .claude/scripts/clickup_intake.py <task_id>` → `{title, description, url}`.

---

## 5. Deliver to GitHub (manual)

Delivery is **manual** — no command creates the commit or opens the PR. After
`/verify` closes the ticket, the developer runs git by hand and opens the PR in the
browser. Stage **explicit paths only** (never `git add -A` — it sweeps unrelated
files):

```bash
git add lib/... assets/languages/*.json .claude/_specs/<slug>/
git restore --staged <anything pre-staged that isn't yours>   # check the index first!
git diff --cached --name-status                               # CONFIRM before committing
git commit -m "feat(<area>): <summary>

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
git push -u origin ticket/<slug>
# GitHub prints a compare URL for pull/new/ticket/<slug>
# open it in the browser, set base = dev_new (branch was cut from dev_new), create
# the PR, then paste the PR URL into ticket.md > links.github
```

This step performs no workflow-state transition; the only thing recorded back is the
PR URL in `ticket.md > links.github`.

---

## 6. Rules that bite (this environment)

| Thing | Rule / reality | Do instead |
|---|---|---|
| generated files | never hand-edit `*.g.dart` / `*.config.dart` / `locale_keys.g.dart` | `sh gen.sh` (build_runner) and `sh keys.sh` (easy_localization); validate with `flutter analyze` |
| hydrated BLoC state | states are persisted via `hydrated_bloc`; changing a state's shape breaks existing installs | treat shape changes as high_risk, keep fields nullable/defaulted, rehearse rollback with an old payload |
| localization | 4 bundles must stay in sync (`en-US`, `ar-SY`, `ku-IQ`, `tr-TR`); Kurdish layers on Arabic via `LanguageService.isKurdish` | add the key to **all four**, then `sh keys.sh`; use the `localization-change` profile |
| `main.dart` init order | ordered: hydrated → dotenv → DI → notifications → Sentry → runApp; the FCM background handler re-inits in its own isolate behind `is*Initialized` guards | never reorder; any insertion is high_risk |
| new `ServerName` | base-URI resolution + per-server tokens/headers are cross-cutting | high_risk; update `detect_server.dart`, the `*_url_routes.dart` config and `.env` together |
| `lib/core/domin/` | the domain dir is spelled `domin` (baked-in typo) | match the existing path; do not "fix" it inside a ticket |
| `.env` | required at runtime, gitignored, holds all base URLs + keys | never commit it; add `CLICKUP_API_TOKEN` there for §4 |
| Review gates | self-review is OFF (`allow_self_review.standard: false`) | a human is the reviewer of record, distinct from the AI author |
| `/implement` branch base | this repo has **no `main`** — base is `dev_new` | `git pull origin dev_new` then branch `ticket/<slug>` from a clean `dev_new` |
| ClickUp writes | MCP license-locked | REST API + `.env` token (§4) |
| Arabic ticket bodies | the ASCII-fold trick in §4 destroys Arabic | post UTF-8; strip only decorative glyphs |
| pre-staged index | rides into commits even after targeted `git add` | `git diff --cached` + `git restore --staged` before every commit |
| high-risk paths | need `mode: high_risk` | 1 approval (not the author) + ADR + rollback rehearsal |

---

## 7. Reference map

- Ticket writing standard: `writing-tickets.md` + `references/` (in this skill)
- Ticket state (single source of truth): `.claude/_specs/<slug>/ticket.md > state`
- All stage artifacts: `.claude/_specs/<slug>/`
- Command definitions: `.claude/commands/*.md`
- Templates: `.claude/_specs/_templates/*.md`
- Canonical rules/config: `.claude/rules/*.md`, `.claude/project-config.yaml`
- Project architecture & conventions: root `CLAUDE.md`
