"""Write the unit-test job summary shown on the GitHub Actions run page.

Three blocks, each read from a file the test job already produced:

  1. Test coverage   - coverage/lcov.info, generated code left out
  2. Test results    - the `flutter test --file-reporter json:...` event log
  3. Ledger progress - the scenarios ticked in docs/test-ledger.html

Usage:
  python .github/scripts/test_summary.py \
      --lcov coverage/lcov.info \
      --results test-results.json \
      --ledger docs/test-ledger.html

The summary goes to $GITHUB_STEP_SUMMARY when it is set, and to stdout
otherwise, so the same command can be run locally to preview it. The script
never decides pass or fail: the job fails on the test command's own exit code.
"""

import argparse
import json
import os
import re
import sys

# Generated files are not hand-written code, and counting them would move the
# percentage every time the generators run. Mirrors the "Generated code" entry
# in CLAUDE.md's protected paths.
GENERATED = re.compile(
    r"(\.g\.dart|\.config\.dart|\.freezed\.dart|\.gr\.dart|\.mocks\.dart)$"
    r"|(^|/)lib/generated/"
)


# Which layer a file belongs to. The overall number counts every file the tests
# load, and most of that is UI a unit test never renders — pages and widgets are
# covered by `integration_test/`, not by `flutter test`. Splitting by layer keeps
# the headline honest and shows where the unit tests actually reach.
AREAS = (
    ("Blocs", ("/presentation/manager/", "/blocs/", "/bloc/")),
    ("Data + domain", ("/data/", "/domain/", "/domin/")),
    ("Core", ("/core/",)),
    ("UI — pages and widgets", ("/presentation/pages/", "/presentation/widgets/",
                                "/app_widgets/")),
)


def area_of(path):
    for name, markers in AREAS:
        if any(m in path for m in markers):
            return name
    return "Other"


def coverage(lcov_path):
    """Return {area: [hit, found]} over hand-written lines, from DA records."""
    if not os.path.exists(lcov_path):
        return None
    areas = {}
    current = None
    with open(lcov_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("SF:"):
                path = line[3:].replace("\\", "/")
                current = None if GENERATED.search(path) else area_of(path)
                if current:
                    areas.setdefault(current, [0, 0])
            elif line.startswith("DA:") and current:
                areas[current][1] += 1
                if int(line[3:].split(",")[1]) > 0:
                    areas[current][0] += 1
    return areas


def results(results_path):
    """Count passed / failed / skipped, and name what failed."""
    passed = failed = skipped = 0
    failures = []
    if not os.path.exists(results_path):
        return None
    names = {}
    with open(results_path, encoding="utf-8") as f:
        for raw in f:
            raw = raw.strip()
            if not raw.startswith("{"):
                continue
            try:
                event = json.loads(raw)
            except ValueError:
                continue
            kind = event.get("type")
            if kind == "testStart":
                test = event.get("test", {})
                names[test.get("id")] = test.get("name", "")
            elif kind == "testDone":
                name = names.get(event.get("testID"), "")
                ok = event.get("result") == "success"
                # A hidden test is the "loading <file>" pseudo-test. It only
                # matters when it failed - that is a file that did not compile,
                # and every test inside it silently never ran.
                if event.get("hidden"):
                    if not ok:
                        failed += 1
                        failures.append(name)
                    continue
                if event.get("skipped"):
                    skipped += 1
                elif ok:
                    passed += 1
                else:
                    failed += 1
                    failures.append(name)
    return passed, failed, skipped, failures


def ledger(ledger_path):
    """Return [(wave id, title, written, total)] from the ledger page."""
    if not os.path.exists(ledger_path):
        return None
    with open(ledger_path, encoding="utf-8") as f:
        page = f.read()
    data = re.search(
        r'<script id="data" type="application/json">(.*?)</script>', page, re.S
    )
    state = re.search(
        r'<script id="state" type="application/json">(.*?)</script>', page, re.S
    )
    if not data:
        return None
    tiers = json.loads(data.group(1))["tiers"]
    checked = set(json.loads(state.group(1)).get("checked", [])) if state else set()
    waves = []
    for tier in tiers:
        total = written = 0
        for group in tier["groups"]:
            for unit in group["units"]:
                for i in range(len(unit["s"])):
                    total += 1
                    if f"{unit['id']}#{i}" in checked:
                        written += 1
        waves.append((tier["id"], tier["title"], written, total))
    return waves


def bar(done, total, width=20):
    filled = round(width * done / total) if total else 0
    return "█" * filled + "░" * (width - filled)


def pct(done, total):
    return f"{100 * done / total:.1f}%" if total else "n/a"


def render(cov, res, waves):
    out = []

    # Headline: how much of the unit-test plan is written, and whether it all
    # passes. This is the number the team tracks — scenarios from the ledger.
    out.append("## Unit tests")
    out.append("")
    if waves:
        written = sum(w[2] for w in waves)
        total = sum(w[3] for w in waves)
        out.append(f"### {pct(written, total)} of unit test scenarios written")
        out.append("")
        line = f"`{written}` of `{total}` scenarios"
    else:
        out.append("### test ledger not found")
        out.append("")
        line = "no `docs/test-ledger.html`"
    if res:
        passed, failed, skipped, _ = res
        line += f" · {passed} passed · {failed} failed · {skipped} skipped"
    out.append(line)
    out.append("")

    if res and res[1]:
        out.append("### ❌ Deployment stopped — failing tests")
        out.append("")
        for name in res[3]:
            out.append(f"- `{name}`")
        out.append("")

    if waves:
        out.append("| Wave | Written | Progress |")
        out.append("|------|--------:|----------|")
        for wave_id, title, done, count in waves:
            out.append(
                f"| {wave_id} {title} | {done} / {count} | "
                f"`{bar(done, count)}` {pct(done, count)} |"
            )
        out.append("")

    # Line coverage, folded away: useful to engineers, easy to misread as the
    # headline. It counts every file the tests load, most of it UI that unit
    # tests never render.
    hit = sum(v[0] for v in cov.values()) if cov else 0
    found = sum(v[1] for v in cov.values()) if cov else 0
    if found:
        out.append("<details>")
        out.append(
            f"<summary>Line coverage: {pct(hit, found)} "
            f"({hit} of {found} lines loaded by the tests)</summary>"
        )
        out.append("")
        out.append("| Layer | Covered lines | Coverage |")
        out.append("|-------|--------------:|----------|")
        order = [name for name, _ in AREAS] + ["Other"]
        for name in order:
            if name not in cov or not cov[name][1]:
                continue
            h, n = cov[name]
            out.append(f"| {name} | {h} / {n} | `{bar(h, n)}` {pct(h, n)} |")
        out.append("")
        out.append(
            "Unit tests cover the logic layers. Pages and widgets are covered "
            "by `integration_test/`, which needs a device and does not run here."
        )
        out.append("")
        out.append("</details>")
        out.append("")

    return "\n".join(out) + "\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--lcov", default="coverage/lcov.info")
    parser.add_argument("--results", default="test-results.json")
    parser.add_argument("--ledger", default="docs/test-ledger.html")
    args = parser.parse_args()

    summary = render(
        coverage(args.lcov), results(args.results), ledger(args.ledger)
    )

    target = os.environ.get("GITHUB_STEP_SUMMARY")
    if target:
        with open(target, "a", encoding="utf-8") as f:
            f.write(summary)
    else:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stdout.write(summary)


if __name__ == "__main__":
    main()
