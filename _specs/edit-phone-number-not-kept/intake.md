---
ticket: edit-phone-number-not-kept
workflow: hotfix
stage: intake
status: blocked
owner: developer
updated: 2026-09-08
links:
  clickup: z8n6b5x09d
---

# Incident Intake — edit-phone-number-not-kept

> First stage. Qualify the incident and **prove it reproduces**. No diagnosis, no
> root cause, no fix.

## Observed Symptoms

On the verification-method screen the confirmed phone number is shown with an
edit-pen icon next to it. Tapping that pen goes back to the phone screen, and the
phone field is empty.

What the owner reports seeing on return:

- the field shows only the hint text (`LocaleKeys.phone_number`),
- no country code and no digits,
- the country flag that was next to the field is gone,
- the submit arrow at the end of the field is hidden again.

The whole number has to be typed again.

## Affected Systems & Users

Two places in the authentication flow, both reported by the owner:

- `lib/features/authentication/presentation/pages/first_registeration_page.dart`
  — the registration / login flow (`RegistrationPage`).
- `lib/features/authentication/presentation/widgets/guest_phone_verification_dialog.dart`
  — the guest phone-confirmation dialog.

Both host `InsertPhoneTab` and `VerificationMethods` inside one `PageView`.

Reach: every user who taps the pen instead of the system back gesture. The count
is not known. Reported in `ar-SY`; the owner states it is not locale-dependent.

No user is blocked by this. The number can still be typed again and the flow
continues, so nothing is unreachable.

## First Observed

**Not recorded.** The owner did not give a date, and no deploy, config change or
dependency update has been tied to it. See **Missing Information** — this is not
one of the four gate items, so it does not by itself decide readiness.

## Reproduction Proof

**The entry condition for this workflow — three questions.** All three answers are
required, and answer 3 is not an answer without its source.

| # | Question | Answer |
|---|---|---|
| 1 | **Can we reproduce it?** | Every time. From `RegistrationPage`: tap **I have an account** (or **Create new account** then **Agree and continue**) → on `InsertPhoneTab` type `963934330889` and tap the submit arrow at the end of the field → `VerificationMethods` opens showing `963934330889` with the `AppAssets.editPenSvg` pen to its right → tap the pen. The same steps reproduce it inside `GuestPhoneVerificationDialog`. |
| 2 | **What is wrong?** | The phone field comes back empty: hint text `LocaleKeys.phone_number` only, no country code, no digits, no country flag, and the submit arrow hidden again. |
| 3 | **What should happen, and what proves it?** | Expected: the pen returns to the phone screen with the confirmed number still in the field, in its formatted form, the country flag shown and the submit arrow enabled. Source offered: (a) `verification_methods.dart:266-279` — the pen sits next to the number it belongs to; (b) `first_registeration_page.dart:305` and `guest_phone_verification_dialog.dart:130` — the host keeps the number in its own state. **Neither source holds. See the check below.** |

| | |
|---|---|
| Artifact under test | `dev_new@16bc20a3`, working tree dirty (16 changed or untracked paths, including `lib/features/authentication/**` and `lib/features/home/**`) — `derived` |

Derived per ADR-034 from `git rev-parse --abbrev-ref HEAD` / `--short HEAD` and
`git status --porcelain`. The reproduction is a set of taps in the app, so it
names no deployment of its own. The dirty tree is recorded because `verify` will
re-run `AC-1` against a named thing, and this one is not a clean checkout.

### Check of the source offered for answer 3

Both sources were read before this file was written. This check is not a
diagnosis. It asks one thing only: does something outside this work item already
establish the expected behaviour?

**(a) The pen sits next to the number.** True as described — in
`verification_methods.dart` the `InkWell(onTap: widget.goBackToPhone)` carrying
`AppAssets.editPenSvg` is in the same `Row` as `MyTextWidget(widget.phoneNumber)`.
But this is a reading of what the layout *means*. It is an argument about intent,
not a recorded expectation. The callback's own name is `goBackToPhone`, and going
back to the phone screen is what it does. Nothing in the file says the field
should arrive filled.

**(b) An existing host-to-widget contract.** This one does not hold. The host does
keep the number:

- `first_registeration_page.dart` sets `this.phoneNumber` inside
  `InsertPhoneTab.moveToNextStep`, then passes it to `VerificationMethods` and
  `VerifyOtp`;
- `guest_phone_verification_dialog.dart` does the same with `_phoneNumber`.

But **neither host ever passes it to `InsertPhoneTab`, and `InsertPhoneTab` has no
parameter that could receive it.** Its constructor takes exactly `fromLogin`,
`moveToNextStep` and `focusNode`. Its text comes from `form.controllers[0]`, which
`FormStateMinxin` creates empty. So no contract is being broken here. The value
existing in the host proves the data is available. It does not prove that anything
was ever meant to carry it back.

**No previous known-good behaviour either.** `git log -p --follow` over
`insert_phone_tab.dart` (4 commits: `6e5bb742`, `75409ef0`, `1d462a4b`,
`5bf52176`) shows no `initialValue`, no phone-number parameter, and no
`AutomaticKeepAliveClientMixin` at any point. The widget has never been able to
start with a number in it.

**No test covers it.** No match for `editPen`, `goBackToPhone`, `InsertPhoneTab`
or `loginPhoneFormField` under `test/` or `docs/`.

So the expectation is being **decided here**, not restored. That is `development`
work, and the decision belongs in a `spec.md`.

> **One source could not be reached.** `clickup_id=z8n6b5x09d` returned
> `CU-2 ERROR: ClickUp task 'z8n6b5x09d' fetch failed: HTTP 401`. If the ticket
> description or a design linked from it records this behaviour as agreed, that
> would be a valid source and would change this outcome. It could not be read.

## Workflow Type Check

- Is the current behaviour **reproducible** by the command or step recorded above?
  **Yes** — the steps in answer 1 reproduce it every time, in two places.
- Does it contradict a **defined expectation whose source is recorded above?**
  **No.** Both offered sources fail: (a) is an interpretation of layout, (b)
  describes a contract that does not exist. No prior commit and no test establish
  it either. → `development`.
- Is the change expected to stay confined to the cause of that failure?
  **Unknown, and probably not.** Carrying the number back needs a new input on
  `InsertPhoneTab` (or its controller lifted into the host), plus the matching
  change in both hosts. Provisional, and moot while the answer above is `No`.
- Is the answer already in the repository, with nothing to change? **No.**
- Is a choice between options still open? **Partly.** *How* the number is carried
  back is a design choice, but the first open question is *whether* it should be,
  which is a `spec.md` question, not a `research` one.

**How the type was resolved:**

| | |
|---|---|
| Resolved type | `hotfix` (as started) — this stage finds it does not qualify; see Readiness Status |
| Source | `argument` |
| ClickUp field said | — (fetch failed, HTTP 401) |
| Argument said | `hotfix` |

The argument was explicit, so it won and was not re-proposed. The ClickUp field
could not be read, so the two never disagreed. What holds this work item is the
readiness gate, not the type argument.

## Missing Information

1. **A source for the expected behaviour** — the one gate item that is missing.
   Something outside this work item saying the number should survive the pen: a
   design file, the ClickUp description, an agreed UX decision, a prior `AC-n`.
2. **ClickUp access** — the `HTTP 401` above. The task description is the most
   likely place where item 1 already exists. **Retried on 2026-09-08 through
   `/wf:next`: same `HTTP 401`.** This is an auth failure, not a temporary one, so
   retrying it again will not help. Someone has to fix the token or read the task
   by hand.
3. **First observed** — not a gate item, but `diagnose` will want it.

> **Gate re-run 2026-09-08 (`/wf:next`).** Nothing the gate depends on had
> changed: `HEAD` still `16bc20a3`, the ClickUp seed still `401`, and no scenario
> for this screen anywhere in `docs/test-ledger.html`. Same result, so no outcome
> was recorded and `ticket.md` was not touched. The gate needs a source, not
> another execution.

## Readiness Status

`NOT READY`

- Justification: questions 1 and 2 are answered well, and the artifact under test
  is recorded. **Question 3 is not answered.** The expected behaviour is stated
  clearly, but neither offered source establishes it, and no commit, test or
  contract elsewhere in the repository does either. Under the gate, an expectation
  without a source is a missing answer, not a partial one.
- The work item stays at `current_stage: intake`. No outcome is recorded and no
  transition is written.
- **Two ways forward:** produce the source named in item 1 above, after which this
  stage can be re-run and can pass; or start this as a `development` work item,
  where the expectation is settled in a `spec.md` instead of assumed.
