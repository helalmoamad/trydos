---
ticket: unit-tests-wave-02-account-session
title: Unit tests for wave 02 — account and session
workflow:
  type: development
  version: 2
  current_stage: intake
  capabilities: []
status: active
owner: developer
created_at: 2026-09-05
updated_at: 2026-09-05
links:
  clickup: ""
  github: ""
---

# Ticket Record — unit-tests-wave-02-account-session

> This file owns the ticket's lifecycle position in one field:
> `workflow.current_stage`. Stage artifacts never own workflow state.
> Do not hand-edit `workflow.current_stage` or `status` outside a transition.

## Why this is `development` and not `hotfix`

The `hotfix` workflow admits a work item only on an **evidenced reproduction**:
a command that fails against a released artifact, the wrong output it prints,
and an independent source for what the right output would be (ADR-030 §2, and
the three questions in `workflows/hotfix/templates/intake.md`).

This ticket has none of those. Nothing is failing. It adds test coverage that
does not exist yet. Under the hotfix readiness gate it would be held at
`intake`, so it runs as `development`.

A separate finding from wave 01 **does** meet the hotfix entry condition and is
listed under **Follow-ups** below.

## Scope

Write the 47 test scenarios of wave 02 (**Account and session**) from the test
ledger at `docs/test-ledger.html`. Waves 00 and 01 are already done: 51 of 366
scenarios, 49 tests green, every unit mutation-checked.

Wave 02 covers what a user does to get into the app, stay in, and manage who
they are. The scenarios are written as flow tests: a mocked `Dio` at the bottom,
and the real repository / use case / bloc chain above it.

### Units in this wave

| Priority | Scenarios | Unit | Reads |
|----------|-----------|------|-------|
| P0 | 3 | Continue as guest | `auth_bloc.dart` |
| P0 | 3 | Request an OTP | `auth_bloc.dart` |
| P0 | 4 | Verify the OTP | `auth_bloc.dart` |
| P0 | 6 | The four-server login | `auth_bloc.dart` |
| P0 | 4 | Staying in | `auth_bloc.dart` |
| P0 | 5 | Logging out | `prefs_repository_impl.dart` |
| P0 | 4 | Edit the profile | `home_bloc.dart` |
| P1 | 2 | Change the display name everywhere | `auth_bloc.dart` |
| P0 | 5 | Country and currency | `home_bloc.dart` |
| P1 | 6 | Notification settings | `home_bloc.dart` |
| P1 | 2 | The notification inbox | `home_bloc.dart` |
| P0 | 3 | AuthBloc contract | `auth_bloc.dart` |

**Wave gate:** done when signin proves four tokens land in four distinct keys,
and every profile edit is covered.

## Files this ticket writes

Only test files and one shared helper:

- `test/features/authentication/**` — new
- `test/core/data/repository/prefs_repository_impl_test.dart` — new
- `test/helpers/hydrated_storage_harness.dart` — new; an in-memory
  `HydratedStorage`, needed because `AuthBloc` is a `HydratedBloc` and cannot be
  constructed without one. Writing it also closes one open scenario in wave 00.
- `test/helpers/network_harness.dart` — extend the existing fakes as needed

## Files this ticket does NOT write

This ticket **reads** protected runtime paths and **changes none of them**:

- `lib/features/authentication/**`
- `lib/core/data/repository/prefs_repository_impl.dart`
- `lib/core/domin/repositories/prefs_repository.dart`

If a test cannot be written without changing one of these, that is a hard stop:
raise it rather than editing the file. Waves 00 and 01 held this line — `lib/`
was byte-identical after every mutation run.

## Definition of done

1. All 47 scenarios have a test, and `flutter test` is green.
2. `flutter analyze` reports no issues.
3. Every unit is **mutation-checked**: break the code it covers on purpose,
   confirm the right test goes red, restore the file, confirm `git status lib/`
   is clean. A test that cannot fail is not counted as done.
4. `docs/test-ledger.html` is regenerated with the wave 02 scenarios ticked, and
   `test/README.md` records the units and their mutation counts.
5. Any defect found while writing a test is pinned by a characterization test
   with a comment naming it as a defect, and reported — not silently fixed.

## Validation strategy

Profile: `flutter-standard` (`flutter analyze`, `depth: all-ac`).

**Open question for the Workflow Owner.** `.claude/project-config.yaml` says
tests are not run as part of a workflow stage, so `plan.md > Tests` must record
`none - <reason>` for every `AC-n`. For a ticket whose entire output is tests,
that leaves the acceptance criteria validated by static analysis alone. Two ways
forward, to be decided at `/plan`:

- add a `flutter-test` entry to `validation_checks` and a profile that requires
  it — a change to the project half of the config, which is a governance change;
- or keep `flutter-standard` and accept that `flutter test` is run and reported
  by hand in `verify.md` until the CI gate exists.

## Follow-ups found in wave 01 — not in this ticket

Three defects were found while writing the wave 01 tests. Each is pinned by a
characterization test that will fail the moment it is fixed, so none can be
fixed silently.

1. **Bearer token leaks between servers.** `BaseApi` mutates the shared
   `client.options.headers` in place and only ever adds the bearer, never
   removes it. After any authenticated request, a request to a public server
   (`elastic`, `cloudinary`, `gemini`, `webApp`, `location`, `mediaServer`) still
   carries the previous token. **This one meets the `hotfix` entry condition** —
   see below.
2. **`TryAgainException` loses `tryCount`.** It has no `on` clause in
   `handlingExceptionRequest`, so it lands in the general `catch` and returns
   `ServerFailure(400)`. No bloc can act on the retry count.
3. **`RequiredValidator` accepts `null`.** `... ?.isNotEmpty ?? true` treats a
   field that was never touched as filled in.

### Hotfix candidate — the token leak

The three entry answers already exist, which is why this one qualifies and this
ticket does not:

| # | Question | Answer |
|---|----------|--------|
| 1 | Can we reproduce it? | `flutter test test/core/api/base_api_test.dart` |
| 2 | What is wrong? | A request built for `ServerName.elastic` carries `Authorization: Bearer <the previous server's token>` |
| 3 | What should happen, and what proves it? | A public server carries no bearer at all — source: `getServerToken()` returns `null` for those six servers, asserted independently in `test/core/api/methods/detect_server_test.dart` |

`lib/core/api/**` is a protected runtime path, so the fix needs its own approved
work item.

## State History

```yaml
- from_stage: null
  to_stage: intake
  event: ticket-created
  result: passed
  by: ai_agent
  timestamp: 2026-09-05
```
