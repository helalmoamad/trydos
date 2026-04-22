# Copilot Merge Review Instructions (Trydos)

Use this document as the default quality gate for every PR before merge.
Keep reviews practical, risk-focused, and production-safe.

## 1) Scope And Safety
- Confirm the PR has a clear goal and no unrelated changes.
- Reject hidden behavioral changes not described in the PR.
- Verify backward compatibility for existing user flows.
- Prefer small, focused commits over large mixed refactors.

## 2) Architecture And Code Quality
- Follow existing project structure and naming conventions.
- Keep business logic out of UI widgets when possible.
- Avoid duplicated logic; extract reusable helpers/services.
- Ensure null-safety is respected and avoid force unwraps unless proven safe.
- Keep methods small and readable; add comments only when logic is non-obvious.

## 3) Flutter Performance
- Prevent unnecessary rebuilds (const constructors, proper widget split).
- Validate list and scroll performance (large lists, image-heavy screens).
- Ensure image loading/caching is efficient and does not increase memory pressure.
- Avoid expensive work in build methods.
- Ensure async operations are cancellable or safely handled on dispose.

## 4) State Management And Async
- Verify BLoC/Cubit states are complete: loading, success, empty, error.
- Ensure no race conditions in concurrent events.
- Validate retry/error paths and user feedback on failures.
- Check Hydrated BLoC persistence for schema safety when state shape changes.

## 5) Networking And Data
- Validate Dio request/response models and JSON parsing correctness.
- Ensure API errors are mapped to clear domain/app errors.
- Confirm timeouts, retries, and offline handling are sensible.
- Never log sensitive payloads or tokens.

## 6) Security, Privacy, And Secrets
- No hardcoded secrets, tokens, keys, or private URLs in source.
- Keep .env usage safe; never expose secrets in logs or analytics.
- Verify permission requests are minimal and justified.
- Ensure files/media access paths do not leak private user data.

## 7) Localization And UX Consistency
- Keep localization keys complete and synced across languages.
- Verify RTL/LTR layouts (especially Arabic) for spacing and alignment.
- Preserve accessibility basics: tap targets, readable contrast, semantic labels where relevant.
- Ensure loading, empty, and error UI states are user-friendly.

## 8) Platform And Integration
- Validate Android/iOS permission and manifest/plist changes.
- Review Firebase integrations (core, messaging, analytics, database) for config safety.
- Ensure notification/callkit flows do not break app lifecycle behavior.
- Confirm webview/camera/file operations handle denied permissions and failures.

## 9) Dependencies And Build Health
- New package additions must be justified (size, maintenance, license).
- Prefer pinned/compatible versions; avoid risky unnecessary upgrades.
- Run and pass static analysis with no new warnings from changed files.
- Ensure code generation outputs are updated when model annotations change.

## 10) Testing And Verification (Merge Minimum)
- Add or update tests for changed business logic.
- Ensure critical paths touched by PR are covered (auth, messaging, media, payments/wallet if impacted).
- Validate at least one happy path and one failure path per major change.
- Smoke test on a real device or emulator for affected features.

## 11) Final Merge Decision
Merge only when all are true:
- Behavior is correct and matches PR intent.
- No critical/performance/privacy regressions introduced.
- Tests and analysis are green for impacted areas.
- Rollback strategy is clear for risky changes.

## Reviewer Output Format (Recommended)
- Summary: 2-4 lines.
- Critical Issues: blocking findings only.
- Non-Blocking Suggestions: improvements.
- Verification: what was checked (analysis/tests/manual).
- Merge Decision: Approve / Request Changes.
