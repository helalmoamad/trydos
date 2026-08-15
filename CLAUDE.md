<!-- wf governance text: v1.0.8 -->

# CLAUDE.md — Engineering Workflow v1

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

## Workflow stages

Canonical stages (see the `wf` plugin's `workflow-config.yaml` and
`rules/workflow-rules.md` for full definitions; the project half of the config
is `.claude/project-config.yaml` in this repository):

1. `intake` — capture and qualify the request.
2. `research` — read-only investigation of the repo and impact.
3. `spec` — define what "done" means (criteria + test cases).
4. `plan` — decide the approach and concrete steps.
5. `review` — a reviewer reviews spec/plan before any code.
6. `implement` — apply the change per the approved plan.
7. `verify` — validate the change and review runtime impact.

Each stage produces an artifact under `_specs/<ticket>/` in this repository,
from the templates in the `wf` plugin's `templates/`.

## Hard stop conditions

Stop immediately and request Workflow Owner direction if any of these occur:

- A change would touch this repository's **protected runtime paths** (listed in
  **Project profile** above) outside an explicitly approved implement stage.
- The request requires deleting or rewriting existing workflow artifacts.
- Acceptance criteria are missing, ambiguous, or untestable.
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
- Do **not** edit the shared governance text below **Project profile** in this
  copy. It is a copy. Change the master in the `wf` plugin
  (`templates/CLAUDE.md`), bump the plugin version, then re-copy.
- Do **not** skip stages or record a gate decision without completing the
  **comprehension check**. The single owner runs their own `/review` and
  `/verify` (self-review is expected; ADR-009) — there is no separate-reviewer
  requirement; the comprehension gate (CG-1..CG-7) is the control against
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
- The comprehension check asks **at least 3 questions — a floor, not a fixed
  count** (ADR-012). Every gate includes **≥1 question on the integration /
  cross-flow axis** (what the change touches outside itself, which other flow
  shares that code or config), sourced from the plan's required
  **Integration surface** section; and `/review` adds **one question per `major`
  panel finding**. A finding may still be dismissed — only after it is understood.
- The **Workflow Owner** owns governance (workflow evolution, governance
  decisions, escalations, cross-project issues), not per-ticket sign-off. Escalate
  to the Workflow Owner only when a hard-stop or governance question arises.

## Small-change philosophy

- Prefer the smallest change that satisfies the acceptance criteria.
- One ticket = one focused outcome; split anything larger.
- Bias toward read-only investigation first; touch code last and minimally.
- Every change must be reversible and individually verifiable.
