<!-- wf governance text: v3.5.0 -->

# CLAUDE.md — Engineering Workflows v3

Governance contract for any AI agent (and human) working in this repository.
This file is authoritative. When in doubt, stop and ask the Workflow Owner.

---

## Project profile — fill this in per repository

> Everything **below** the `---` after this section is the shared governance
> text. Copy it unchanged. Only this block changes per project. When the plugin
> ships a new governance version, re-copy the shared text and keep this block.

**Mission.** This repository hosts *Trydos* — a Flutter mobile app (Dart SDK
`>=3.8.0 <4.0.0`) that combines a marketplace, real-time chat and calls (Agora in
a webview + CallKit), and stories. It is multilingual and RTL-aware (`ar-SY`,
`en-US`, `ku-IQ`, `tr-TR`). The mission of the engineering workflow is to make
every change **small, reviewed, and verifiable**, moving through a fixed set of
stages with explicit review gates — never improvising scope or skipping review.

**Base branch.** This repository has **no `main` branch**. The base for every
ticket branch and every pull request is **`dev_new`**. Ticket branches are named
`ticket/<slug>`. Where the shared governance text or the `wf` plugin says
`main`, read `dev_new`.

**Protected runtime paths.** The paths below are this repository's runtime. They
may be changed **only** inside an approved `implement` stage, and only when the
approved `plan.md` lists them:

- **Auth and session** — `lib/features/authentication/**`,
  `lib/core/data/repository/prefs_repository_impl.dart`,
  `lib/core/domin/repositories/prefs_repository.dart`,
  `lib/common/constant/configuration/prefs_key.dart`
- **API and network** — `lib/core/api/**`,
  `lib/common/constant/configuration/*_url_routes.dart`
- **Composition root** — `lib/main.dart`, `lib/core/di/**`, `lib/base_page.dart`,
  `lib/service/service_provider.dart`, `lib/routes/**`
- **Hydrated BLoC state** — `**/*_state.dart`, `**/*_state.g.dart` (a shape
  change needs a migration path; old stored payloads must still deserialize)
- **Calls and push** — `lib/features/calls/**`,
  `lib/service/notification_service/**`, `lib/service/call_notification_service/**`
- **Money surfaces** — `lib/common/constant/configuration/wallet_url_routes.dart`,
  `lib/features/home/**/*payment*`, `lib/features/home/**/*wallet*`
- **Config and secrets** — `.env`,
  `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`,
  `assets/languages/**`
- **Generated code** — `**/*.g.dart`, `**/*.config.dart`,
  `lib/generated/locale_keys.g.dart` (never hand-edit; regenerate with `gen.sh`
  or `keys.sh`)

Some risks are not path-shaped. Treat a change as touching protected runtime
when it does any of these, even if no file above is listed:

- alters authentication, session, or per-server token handling;
- changes the shape of a `hydrated_bloc` state without a migration path;
- reorders `main.dart`'s ordered init (hydrated storage → dotenv → DI →
  notifications → Sentry → `runApp`), including the
  `_firebaseMessagingBackgroundHandler` isolate guards;
- alters wallet balances, order totals, or the amount of money moved;
- registers a **new app-wide** BLoC in DI + `ServiceProvider`, or changes an
  existing one's registration lifetime (a feature-local BLoC is normal work);
- adds or renames a `ServerName` entry or its base-URI resolution.

---

## Workflow types and stages

Pick the workflow type by what changes when the work is finished: a source file
→ `development`; your understanding of something that already exists → `study`;
a decision about a direction → `research`; a *released* artifact that a command
reproducibly breaks → `hotfix` — that reproduction is the entry condition, never a
severity label. A work item never changes type, and a study never quietly becomes
an implementation.

**`development`** — the stages this repository uses for a change:

1. `intake` — capture and qualify the request.
2. `research` — read-only investigation of the repo and impact.
3. `spec` — define what "done" means (criteria + test cases).
4. `plan` — decide the approach and concrete steps.
5. `review` — review spec/plan, with the comprehension gate, before any code.
6. `implement` — apply the change per the approved plan.
7. `verify` — validate the change and review runtime impact.

**Tests are declared, written, and run — in that order.** `plan.md` maps every
`AC-n` to the test file and case that proves it, or says `none — <reason>`;
`/implement` writes exactly those and no others; `/verify` runs them through the
profile named in `.claude/project-config.yaml` and records the exit code per
`AC-n`. A declared test that never ran is a **failed** verification, not a passed
one — saying it passes is not evidence (PL-13 / IM-11 / VF-11, ADR-026). A test
the approved plan never named is still scope creep at `implement` (IM-4): declare
it first, or revise the plan.

**Look for the test before you write one** (PL-14, ADR-027). Each row of
`plan.md > Tests` records what already covers that `AC-n` and one disposition:
`existing` (already proven — write nothing), `extend` (the unit has a test file,
the case is missing — **add it to that file**), or `new`. **A second, parallel
test file for a unit that already has one is a defect.** `extend` and `new` both
put the file under files to change, an existing file included.

**A test that proves existing behaviour wrong is a finding, not a fix** (IM-12 /
VF-12, ADR-027). Record it as `BUG-n` in `implement.md > Findings` and carry it
into `verify.md > Findings` — scenario, confirming test, where it lives, expected
vs actual — and **open a separate ticket for it**. The scope line is the *file*:
wrong behaviour inside `plan.md > Files to change` is yours to fix here; anywhere
else it is a finding. Keep the confirming test in the suite under the runner's
**strict** expected-failure marker with the `BUG-n` id, so the suite stays green
and the fix ticket cannot land without correcting the test.

**`study`** — `intake → scope → analyze → explain → assess` (read-only; no branch,
no PR). **`research`** — `intake → frame → evidence → evaluate → recommend →
assess → decide` (evaluates options; records a human decision). **`hotfix`** —
`intake → diagnose → patch → verify` (branch `hotfix/<slug>`; one gate, at
`verify`; the minimal patch only — no refactoring, no cleanup).

Each stage produces an artifact under `_specs/<ticket>/` in this repository, from
the templates in the `wf` plugin. The authoritative stage list and the legal
moves between stages live in the plugin's `workflows/<type>/workflow.yaml`, and the
plugin's `rules/lifecycle-protocol.md` says how to move — `_specs/<ticket>/ticket.md`
records the position in `workflow.current_stage` and is written only by the step
that records an outcome, never by hand. Since v3 nothing *refuses* a bad
transition; the state history is what makes one visible afterwards.
`/wf:next <ticket>` runs whatever stage is due.

## Hard stop conditions

Stop immediately and request Workflow Owner direction if any of these occur:

- A change would touch this repository's **protected runtime paths** (listed in
  **Project profile** above) outside an explicitly approved implement stage.
- The request requires deleting or rewriting existing workflow artifacts.
- Acceptance criteria are missing, ambiguous, or untestable.
- A test is needed that the approved `plan.md > Tests` does not declare (revise
  the plan — do not write it and do not skip it).
- A test proves existing behaviour wrong **inside** a file this plan changes, and
  fixing it would grow the change (record it and block — IM-10 — do not improvise).
- A stage's entry criteria are not met (e.g. implementing before plan approval).
- Scope grows beyond what the approved spec/plan describes.

## Language

**Everything written to this repository is in English.** Workflow artifacts,
comprehension questions and their options, review findings, ADRs, commit
messages, and PR text — regardless of the language the request or conversation
used. The conversation may be in any language; the artifacts never are.

**Write that English plainly.** The reader's first language is Arabic, so keep
the wording simple: short sentences, common words, no idioms, no rare or
academic vocabulary. This is about *vocabulary only* — the reader is a senior
engineer. Never simplify the technical content, the depth, or the reasoning, and
keep standard technical terms as they are (`scrape`, `cardinality`, `rollback`,
`AC-n`, …). Simple words, full engineering substance.

## Forbidden actions

- Do **not** write any artifact, comprehension question, or PR/commit text in a
  language other than English (see **Language** above).
- Do **not** create workflow commands unless a phase explicitly authorizes it.
- Do **not** implement tickets during research, spec, plan, or review stages.
- Do **not** modify the **protected runtime paths** (see **Project profile**) as
  part of workflow/governance work.
- Do **not** delete `_specs/`, `.claude/project-config.yaml` (this project's half
  of the config), or `.claude/settings.json` (which enables the `wf` plugin).
- Do **not** hand-edit `ticket.md > workflow.current_stage`, `status`, or its
  state history outside the step that records an outcome. Since v3 no runtime
  refuses a bad transition (ADR-023), so this rule is the whole of the protection:
  editing those fields directly leaves a ticket whose state and history disagree,
  and nothing will tell you.
- Do **not** edit the shared governance text below **Project profile** in this
  copy. It is a copy. Change the master in the `wf` plugin
  (`templates/CLAUDE.md`), bump the plugin version, then re-copy.
- Do **not** skip stages or record a gate decision without completing the
  **comprehension check**. The single owner runs their own `/review` and
  `/verify` (self-review is expected; ADR-009) — there is no separate-reviewer
  requirement; the comprehension gate (CG-1..CG-8) is the control against
  rubber-stamping.

## Review gate requirements

- The gates `/review` and `/verify` are run per ticket by the **owner** themselves
  (self-review; ADR-009). Gate integrity comes from the **comprehension check**
  (the owner answers questions generated from the artifact), not a second person.
  They do **not** require an Engineering Manager.
- The `review` stage is a **mandatory gate**: no `implement` may begin until the
  owner accepts the `spec` and `plan` at `/review` (with the comprehension check
  completed).
- The owner signs off again at `verify` (comprehension check) before a ticket is
  considered done.
- Review decisions are recorded as `CHANGES_REQUESTED` / `REJECTED` / `APPROVED`
  against the relevant stage.
- At `/review`, an **advisory** AI panel (senior / security / performance,
  read-only) reviews the plan and records findings for the owner (ADR-010). It
  **informs** the decision — it never blocks or makes it; the comprehension gate
  remains the control.
- The comprehension check asks **between 3 and 5 questions** — a floor and a
  ceiling (ADR-012, ADR-022). Every gate includes **≥1 question on the
  integration / cross-flow axis** (what the change touches outside itself, which
  other flow shares that code or config), sourced from the plan's required
  **Integration surface** section; and `/review` adds **one question per `major`
  panel finding**, up to the ceiling. A finding may still be dismissed — only
  after it is understood.
- **A question that can be answered without reading the artifact is not a gate**
  (ADR-025). Every option names something that **exists in this project** — a real
  file, component, `AC-n`, flow, decision — never an invented one; the wrong options
  are the right fact slightly bent; the question asks what **is** the case
  here, never what is correct in general; and at least half the questions require
  joining **two** places in the artifacts rather than reading one sentence. Before
  the owner sees them, the questions go — **alone, with no artifacts attached** —
  to a falsifier agent, and any question it can answer from general knowledge is
  thrown out. The four options also share a **shape** — comparable length, same
  form, none uniquely explaining *why* — because an option that stands out by
  construction is pickable with the artifact closed (ADR-028).
- **A gate that cannot be built is administered short, never skipped** (ADR-028).
  When too few questions survive falsification, the gate asks the ones the
  falsifier got **wrong** — even a single question, below the usual floor — records
  how short it was and why in `degraded:`, and that line goes to the team channel
  with a warning icon. Only a set the falsifier answered entirely correctly stops
  the gate outright, and stopping still records no decision.
- **The gate decision is the owner's, and the framework never suggests one**
  (RV-2, ADR-029). At `/review` you are offered exactly `APPROVED`,
  `CHANGES_REQUESTED`, `REJECTED` — no fourth option, none marked recommended,
  and nothing chosen on your behalf. "Review it again" is not a decision: a plan
  that needs work is `CHANGES_REQUESTED`, which returns it to `/wf:plan`, the only
  stage allowed to rewrite a plan. If you are ever offered an extra option or a
  recommendation at a gate, that is a defect — report it.
- **A gate never edits what it reviews** (RV-11 / VF-7). `/review` writes only
  `review.md`, `comprehension.md` and `ticket.md`; `/verify` only `verify.md`,
  `comprehension.md` and `ticket.md`. A stage that rewrites its own evidence and
  then passes it has reviewed its own work.
- The **Workflow Owner** owns governance (workflow evolution, governance
  decisions, escalations, cross-project issues), not per-ticket sign-off. Escalate
  to the Workflow Owner only when a hard-stop or governance question arises.

## Small-change philosophy

- Prefer the smallest change that satisfies the acceptance criteria.
- One ticket = one focused outcome; split anything larger.
- Bias toward read-only investigation first; touch code last and minimally.
- Every change must be reversible and individually verifiable.
