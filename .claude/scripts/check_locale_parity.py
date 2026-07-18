#!/usr/bin/env python3
"""Read-only localization parity check for the `localization-change` profile.

Trydos ships four bundles (en-US, ar-SY, ku-IQ, tr-TR) and CLAUDE.md requires
them to stay in sync when keys are added.

**Scope: newly added keys only.** The bundles carry a large pre-existing parity
debt, so checking the full key set would fail every ticket for reasons that have
nothing to do with that ticket. This check therefore diffs each bundle against
its committed baseline (default `HEAD`) and validates only the keys the working
tree *adds*: every new key must be present in all four bundles. Pre-existing
gaps are reported as an informational count and never fail the check.

Deterministic, non-interactive, read-only (VP-2/VP-3): it reads files and git
objects and prints a report; it never writes.

Exit 0  -> every newly added key exists in all bundles (or nothing was added).
Exit 1  -> at least one newly added key is missing from at least one bundle.
Exit 2  -> setup problem (no bundles / invalid JSON / git unavailable).

Usage:
    py .claude/scripts/check_locale_parity.py [<git-baseline-ref>]
    py .claude/scripts/check_locale_parity.py origin/dev_new
"""
import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
LANG_REL = "assets/languages"
LANG_DIR = REPO_ROOT / LANG_REL


def flatten(node, prefix=""):
    """Every leaf path in a nested translation map, as dotted keys."""
    if isinstance(node, dict):
        keys = set()
        for key, value in node.items():
            keys |= flatten(value, f"{prefix}{key}.")
        return keys
    return {prefix.rstrip(".")}


def keys_from_text(text, label):
    try:
        return flatten(json.loads(text))
    except (json.JSONDecodeError, UnicodeDecodeError) as exc:
        print(f"error: {label} is not valid JSON: {exc}", file=sys.stderr)
        raise SystemExit(2)


def baseline_keys(ref, rel_path):
    """Key set of a bundle at `ref`. Returns None if it did not exist there
    (a brand-new bundle — then all of its keys count as newly added)."""
    proc = subprocess.run(
        ["git", "show", f"{ref}:{rel_path}"],
        cwd=REPO_ROOT, capture_output=True, text=True, encoding="utf-8",
    )
    if proc.returncode != 0:
        return None
    return keys_from_text(proc.stdout, f"{rel_path}@{ref}")


def main(argv) -> int:
    ref = argv[1] if len(argv) > 1 else "HEAD"

    if subprocess.run(["git", "rev-parse", "--verify", ref],
                      cwd=REPO_ROOT, capture_output=True).returncode != 0:
        print(f"error: git baseline ref '{ref}' not found", file=sys.stderr)
        return 2

    bundles = sorted(LANG_DIR.glob("*.json"))
    if not bundles:
        print(f"error: no language bundles found in {LANG_DIR}", file=sys.stderr)
        return 2

    current, base, added_per_bundle = {}, {}, {}
    for bundle in bundles:
        rel = f"{LANG_REL}/{bundle.name}"
        current[bundle.name] = keys_from_text(bundle.read_text(encoding="utf-8"), bundle.name)
        base[bundle.name] = baseline_keys(ref, rel)
        old = base[bundle.name]
        added_per_bundle[bundle.name] = current[bundle.name] if old is None else current[bundle.name] - old

    # A key is "newly added" if any bundle gained it relative to the baseline.
    newly_added = set().union(*added_per_bundle.values())

    # Informational only: parity debt that already existed at the baseline.
    union_now = set().union(*current.values())
    pre_existing_gap = sum(len(union_now - current[name] - newly_added) for name in current)

    print(f"baseline: {ref}")
    print(f"bundles:  {', '.join(b.name for b in bundles)}")
    print(f"newly added keys: {len(newly_added)}")
    if pre_existing_gap:
        print(f"note: {pre_existing_gap} pre-existing missing-key slot(s) ignored (not this ticket's debt)")

    if not newly_added:
        print("\nPASS: no new localization keys added.")
        return 0

    failed = False
    for name in sorted(current):
        missing = sorted(newly_added - current[name])
        if missing:
            failed = True
            print(f"\n{name}: missing {len(missing)} newly added key(s)")
            for key in missing:
                print(f"  - {key}")

    if failed:
        print("\nFAIL: a newly added key is not present in every language bundle.")
        print("Add it to all four bundles, then run `sh keys.sh`.")
        return 1

    print(f"\nPASS: all {len(newly_added)} newly added key(s) present in every bundle.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
