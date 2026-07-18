# Workflow Governance — Engineering Workflow v1 (Trydos)

Governance contract for any AI agent (and human) working in this repository under
the engineering workflow. This file is authoritative for **workflow conduct**;
the root `CLAUDE.md` remains authoritative for **codebase architecture and
conventions**. When in doubt, stop and ask the Workflow Owner.

## Mission

This repository hosts **Trydos** — a Flutter mobile app combining a marketplace,
real-time chat/calls (Agora via webview + CallKit), and stories (Clean
Architecture, BLoC + hydrated_bloc, dio, get_it+injectable, dartz, go_router,
easy_localization). The mission of the engineering workflow is to make every
change **small, reviewed, and verifiable**, moving through a fixed set of stages
with explicit review gates — never improvising scope or skipping review.
Authentication/session safety, the integrity of persisted (hydrated) BLoC state
on users' devices, and the correctness of wallet/order money surfaces are
first-class safety concerns at every stage.

## Workflow stages

Canonical stages (see `.claude/project-config.yaml` and
`.claude/rules/workflow-rules.md` for full definitions):

1. `intake` — capture and qualify the request.
2. `research` — read-only investigation of the repo and impact.
3. `spec` — define what "done" means (criteria + test cases).
4. `plan` — decide the approach and concrete steps.
5. `review` — a reviewer reviews spec/plan before any code.
6. `implement` — apply the change per the approved plan.
7. `verify` — validate the change and review runtime impact.

Each stage produces an artifact under `.claude/_specs/<ticket>/` from the templates in
`.claude/_specs/_templates/`.

## High-risk triggers (Trydos)

The sample workflow keyed `high_risk` to a single narrow runtime concern. In
Trydos, `high_risk` mode (1 approval by a non-author reviewer + mandatory ADR +
rollback rehearsal) is required whenever a change touches any **high-risk path**
defined in `.claude/project-config.yaml > high_risk_paths`:

- **Auth & session** — `lib/features/authentication/**`,
  `lib/core/data/repository/prefs_repository_impl.dart`,
  `lib/core/domin/repositories/prefs_repository.dart`,
  `lib/common/constant/configuration/prefs_key.dart` (login/OTP, token and
  session storage, per-server tokens).
- **API / network** — `lib/core/api/**` (dio, `BaseApi` headers/tokens, server
  detection, `methods/**`) and `lib/common/constant/configuration/*_url_routes.dart`,
  including **adding or renaming a `ServerName`** or changing base-URI resolution.
- **Composition root** — `lib/main.dart` (its **ordered** init: hydrated storage →
  dotenv → DI → notifications → Sentry → runApp, plus the FCM background-isolate
  guards), `lib/core/di/**`, `lib/base_page.dart`,
  `lib/service/service_provider.dart`, `lib/routes/**`.
- **Persisted (hydrated) BLoC state** — any `*_state.dart` whose `*_state.g.dart`
  is persisted by `hydrated_bloc`; a shape change must still deserialize the
  payloads already on users' devices.
- **Calls & push** — `lib/features/calls/**` (Agora webview flow),
  `lib/service/notification_service/**`, `lib/service/call_notification_service/**`
  (CallKit, FCM background handler).
- **Money surfaces** — wallet routes and order-total/payment widgets — anything
  affecting balances shown or money moved
  (`lib/common/constant/configuration/wallet_url_routes.dart`,
  `lib/features/home/**/*payment*`, `lib/features/home/**/*wallet*`).
- **Config & secrets, generated code** — `.env`, native manifests, firebase
  config, `assets/languages/**`; `**/*.g.dart`, `**/*.config.dart`,
  `lib/generated/locale_keys.g.dart`.

**Cross-cutting rule:** any change that alters authentication/session/token
handling or per-server token wiring, changes the SHAPE of a persisted
`hydrated_bloc` state without a migration path, reorders or inserts steps in
`main.dart`'s ordered initialization, alters wallet balances / order totals / the
amount of money moved, registers a **NEW app-wide BLoC** in DI +
`ServiceProvider` (or changes an existing registration's lifetime), or adds or
renames a `ServerName` is `high_risk` even if its file is not globbed above.

> **Not** a trigger by itself: adding a *feature-local* BLoC. Trydos legitimately
> runs many BLoCs (auth, chat, home, order, story, category, boutique,
> pre-caching); only app-wide registration is high_risk.

## Hard stop conditions

Stop immediately and request Workflow Owner direction if any of these occur:

- A change would touch a **high-risk path** (see above) outside an explicitly
  approved `implement` stage running in `high_risk` mode.
- The request requires deleting or rewriting existing workflow artifacts.
- Acceptance criteria are missing, ambiguous, or untestable.
- A stage's entry criteria are not met (e.g. implementing before plan approval).
- Scope grows beyond what the approved spec/plan describes.
- A change would let a user access another account/session, leak or cross-use
  tokens between servers, break persisted `hydrated_bloc` state on existing
  installs, or perform an unauthorized wallet/order action (session & security
  breach).

## Forbidden actions

- Do **not** create workflow commands unless a phase explicitly authorizes it.
- Do **not** implement tickets during research, spec, plan, or review stages.
- Do **not** modify high-risk paths as part of workflow/governance work, or in
  any mode other than an approved `high_risk` implement stage.
- Do **not** hand-edit generated code (`*.g.dart`, `*.config.dart`,
  `lib/core/di/di_container.config.dart`, `lib/generated/locale_keys.g.dart`) —
  change the sources (`@injectable`, `json_serializable`, models, DI,
  `assets/languages/*.json`) and regenerate with `sh gen.sh`
  (`dart run build_runner build --delete-conflicting-outputs`) or `sh keys.sh`
  (easy_localization locale keys).
- Do **not** add a localization key to only one bundle — all four
  (`assets/languages/{en-US,ar-SY,ku-IQ,tr-TR}.json`) must stay in sync, then
  regenerate with `sh keys.sh`. Kurdish (`ku-IQ`) layers on Arabic.
- Do **not** delete `.claude/_specs/`, `.claude/commands/README.md`, or
  `.claude/project-config.yaml` (the canonical config).
- Do **not** skip stages or self-approve work that requires review. Separation
  of duties (RA-1..RA-3) requires the `reviewer` gate actor to differ from the
  author, **except** for `standard` low-risk tickets when self-review is
  explicitly enabled (`separation_of_duties.allow_self_review.standard: true`).
  `high_risk` never self-reviews.

## Review gate requirements

- The gates `/review` and `/verify` are owned per ticket by a **reviewer** — any
  qualified team member who is **not** the ticket's author. They do **not**
  require an Engineering Manager; the workflow never depends on EM participation
  per ticket.
- The `review` stage is a **mandatory gate**: no `implement` may begin until a
  reviewer accepts the `spec` and `plan`.
- A reviewer signs off again at `verify` before a ticket is considered done.
- Review decisions are recorded as `CHANGES_REQUESTED` / `REJECTED` / `APPROVED`
  against the relevant stage.
- The **Workflow Owner** owns governance (workflow evolution, governance
  decisions, escalations, cross-project issues), not per-ticket sign-off.
  Escalate to the Workflow Owner only when a hard-stop or governance question
  arises.

## Small-change philosophy

- Prefer the smallest change that satisfies the acceptance criteria.
- One ticket = one focused outcome; split anything larger.
- Bias toward read-only investigation first; touch code last and minimally.
- Every change must be reversible and individually verifiable.

## Relationship to other docs

- `CLAUDE.md` (repo root) — codebase architecture, modules, commands, conventions.
- `.claude/project-config.yaml` — canonical state machine, modes, high-risk
  paths, validation checks/profiles.
- `.claude/rules/workflow-rules.md` — stage definitions, gates, guardrails.
- `.claude/rules/validation-model.md` — the validation rule catalogue.
- `.claude/docs/command-architecture.md` — per-command contracts.
