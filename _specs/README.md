# `_specs/`

Ticket workspaces for **Engineering Workflow v1**, delivered by the `wf` plugin
(`wf@ramaaz-workflows`, enabled in `.claude/settings.json`). Every change moves
through a fixed sequence of stages, each producing one Markdown artifact under
`_specs/<ticket>/`.

## Layout

```
_specs/
  <ticket-slug>/       # one workspace per ticket, created by /wf:start-ticket
    ticket.md          # the single source of truth for workflow state (ADR-003)
    intake.md
    research.md
    spec.md
    plan.md
    review.md          # includes the advisory panel's findings
    comprehension.md   # gate comprehension record (/review and /verify)
    implement.md
    verify.md
```

Artifact templates ship with the plugin (`${CLAUDE_PLUGIN_ROOT}/templates/`) —
they are no longer copied into this repository. A ticket's workflow **state lives
in exactly one place** — `<ticket>/ticket.md > state`; never infer state from
which artifacts exist.

## Stages & commands

`intake → research → spec → plan → review → implement → verify`

```
/wf:start-ticket <slug> "<title>"    /wf:review <slug>
/wf:research <slug>                  /wf:implement <slug>
/wf:spec <slug>                      /wf:verify <slug>
/wf:plan <slug>                      /wf:publish-pr <slug>   (delivery, not a stage)
```

There are **no modes and no risk tiers** (ADR-009): every ticket runs the same
seven stages, owned end to end by one person who runs their own gates. Gate
integrity comes from the **comprehension check**, not a second reviewer.

## Canonical sources

This README is an overview. The authoritative definitions live in:

- [`../CLAUDE.md`](../CLAUDE.md) — governance contract + this repo's protected runtime paths
- [`../.claude/project-config.yaml`](../.claude/project-config.yaml) — project half of the config (validation profiles, git topology, ClickUp ids)
- the `wf` plugin — `workflow-config.yaml` (state machine, gates), `rules/workflow-rules.md`, `rules/validation-model.md`, `docs/command-architecture.md`, `docs/WORKFLOW_V1_RUNBOOK.md`
- [`../docs/trydos-codebase-guide.md`](../docs/trydos-codebase-guide.md) — architecture & conventions

Where this README and a canonical source ever disagree, the canonical source wins.
