#!/usr/bin/env python3
"""Write-side ClickUp helper for /write-ticket — creates ONE task from a payload file.

This is the **only** place the ClickUp write path lives (same isolation pattern as
the plugin's read-only `clickup_intake.py`, ADR-005). `/write-ticket` authors the
markdown, writes a payload file, and invokes this helper. The command embeds no
HTTP.

What it does
  1. Resolves the API token (see "Token resolution" below) and probes it.
  2. Resolves the target list id from `.claude/project-config.yaml > clickup.lists`.
  3. Reads the list's custom fields (read-only GET) and maps requested field
     names/values to ClickUp field ids and dropdown option ids.
  4. Refuses to create a task whose name already exists in the list, unless
     --allow-duplicate is given.
  5. POSTs one task. Prints {"id","url","name","list_id"} as JSON on success.

Writes are limited to creating that single task: no status changes on other
tasks, no comments, no deletes, no updates.

Token resolution (in order; first one that authenticates wins)
  1. `CLICKUP_API_TOKEN` from the environment.
  2. `CLICKUP_API_TOKEN=` from the repo-root `.env`.
Both are tried because this machine's shell environment may carry a stale token
while `.env` holds the working one. The value is never printed — only which
source authenticated.

Usage
  python .claude/scripts/clickup_push.py --payload <file.json> [--dry-run]
                                         [--allow-duplicate]

  --dry-run  resolves everything (token, list, custom fields, duplicates) and
             prints the exact request body WITHOUT creating the task.

Payload schema (all keys optional except `name` and `markdown`)
  {
    "list": "backlog",              # a key of clickup.lists, "test", or a numeric id
    "name": "Create Order",         # task title (verb + object)
    "markdown": "## User Story\n…", # the 3-section body
    "status": "Backlog",
    "assignees": [302565222],       # default: clickup.default_assignee
    "tags": ["flutter"],            # default: clickup.default_tag
    "time_estimate_hours": 4,
    "fields": {                     # ClickUp custom fields, addressed BY NAME
      "Backbone": "Marketplace/Products",
      "Actor": ["Buyer", "Seller"]
    }
  }

Exit codes
  0 success (or a clean --dry-run)   1 usage / config / payload error
  2 auth failure (no token works)    3 ClickUp API rejected the request
  4 duplicate task name in the list
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

API_ROOT = "https://api.clickup.com/api/v2"
TIMEOUT = 30

# The Windows console is cp1252 by default; ticket text is UTF-8.
for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding="utf-8")
    except (AttributeError, ValueError):  # pragma: no cover - non-reconfigurable stream
        pass

# Custom-field types whose value is sent as-is (after a light cast).
PASSTHROUGH_TEXT = {"short_text", "text", "url", "email", "phone"}
PASSTHROUGH_NUMBER = {"number", "currency"}


def repo_root() -> str:
    """The repository root — this file lives at <root>/.claude/scripts/."""
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def die(code: int, message: str):
    print(message, file=sys.stderr)
    raise SystemExit(code)


# ---------------------------------------------------------------------------
# Config — a deliberately small reader for the `clickup:` block only.
# PyYAML is not installed and this helper must not add a dependency. The block
# is plain `key: value` at 2-space indent plus one nested `lists:` map at
# 4-space indent; anything more complex is out of scope on purpose.
# ---------------------------------------------------------------------------
def load_clickup_config() -> dict:
    path = os.path.join(repo_root(), ".claude", "project-config.yaml")
    if not os.path.isfile(path):
        die(1, f"CFG ERROR: {path} not found")

    with open(path, encoding="utf-8") as handle:
        lines = handle.read().splitlines()

    config: dict = {"lists": {}}
    in_block = False
    in_lists = False

    for raw in lines:
        line = raw.split("#", 1)[0].rstrip()
        if not line.strip():
            continue

        if not line.startswith((" ", "\t")):
            # A new top-level key ends the clickup block.
            in_block = line.strip() == "clickup:"
            in_lists = False
            continue
        if not in_block:
            continue

        indent = len(line) - len(line.lstrip())
        stripped = line.strip()
        if ":" not in stripped:
            continue
        key, _, value = stripped.partition(":")
        key, value = key.strip(), value.strip().strip('"').strip("'")

        if indent == 2:
            in_lists = key == "lists"
            if not in_lists and value:
                config[key] = value
        elif indent >= 4 and in_lists and value:
            config["lists"][key] = value

    if not config.get("lists") and "test_list_id" not in config:
        die(1, "CFG ERROR: no `clickup:` block found in .claude/project-config.yaml")
    return config


def token_candidates() -> list[tuple[str, str]]:
    candidates: list[tuple[str, str]] = []
    env_token = (os.environ.get("CLICKUP_API_TOKEN") or "").strip()
    if env_token:
        candidates.append(("environment", env_token))

    env_path = os.path.join(repo_root(), ".env")
    if os.path.isfile(env_path):
        # Tolerate `export `, spaces around `=`, and quoted values.
        pattern = re.compile(r"^\s*(?:export\s+)?CLICKUP_API_TOKEN\s*=\s*(.*)$")
        with open(env_path, encoding="utf-8", errors="replace") as handle:
            for line in handle:
                match = pattern.match(line)
                if match:
                    value = match.group(1).strip().strip('"').strip("'").strip()
                    if value and value not in {tok for _, tok in candidates}:
                        candidates.append((".env", value))
                    break
    return candidates


class Client:
    def __init__(self, token: str):
        self.token = token

    def request(self, method: str, path: str, body: dict | None = None):
        """Returns (status, parsed_body). Never raises on an HTTP error status."""
        data = json.dumps(body).encode("utf-8") if body is not None else None
        request = urllib.request.Request(
            f"{API_ROOT}{path}",
            data=data,
            method=method,
            headers={
                "Authorization": self.token,
                "Content-Type": "application/json",
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
                return response.status, json.load(response)
        except urllib.error.HTTPError as exc:
            raw = exc.read().decode("utf-8", "replace")
            try:
                return exc.code, json.loads(raw)
            except json.JSONDecodeError:
                return exc.code, {"err": raw[:400]}
        except urllib.error.URLError as exc:
            die(2, f"NET ERROR: ClickUp unreachable: {exc.reason}")


def authenticate() -> tuple[Client, str]:
    candidates = token_candidates()
    if not candidates:
        die(
            2,
            "AUTH ERROR: no CLICKUP_API_TOKEN in the environment or in .env",
        )

    for source, token in candidates:
        client = Client(token)
        status, _ = client.request("GET", "/user")
        if status == 200:
            print(f"auth: using token from {source}", file=sys.stderr)
            return client, source
        print(f"auth: token from {source} rejected (HTTP {status})", file=sys.stderr)

    die(2, "AUTH ERROR: every available token was rejected by ClickUp")


def resolve_list_id(config: dict, requested: str | None) -> str:
    lists = config.get("lists", {})
    if not requested:
        target = lists.get("backlog")
        if not target:
            die(1, "CFG ERROR: clickup.lists.backlog is not configured")
        return target
    if requested.isdigit():
        return requested
    if requested == "test":
        target = config.get("test_list_id")
        if not target:
            die(1, "CFG ERROR: clickup.test_list_id is not configured")
        return target
    if requested in lists:
        return lists[requested]
    die(
        1,
        f"PAYLOAD ERROR: unknown list '{requested}' — "
        f"known: {', '.join(sorted(lists) + ['test'])}, or a numeric list id",
    )


def fetch_fields(client: Client, list_id: str):
    status, body = client.request("GET", f"/list/{list_id}/field")
    if status != 200:
        return None, f"could not read custom fields for list {list_id} (HTTP {status})"
    return body.get("fields", []), None


def build_custom_fields(client: Client, list_id: str, requested: dict):
    """Map {field name: value} onto ClickUp field ids.

    Returns (payload, warnings, resolved_names) — `resolved_names` holds the
    lower-cased names actually resolved, so the caller can tell a requested
    field from one that really landed.
    """
    if not requested:
        return [], [], set()

    fields, error = fetch_fields(client, list_id)
    if error:
        return [], [error], set()

    available = {(field.get("name") or "").strip().lower(): field for field in fields}
    payload, warnings, resolved = [], [], set()

    for name, value in requested.items():
        field = available.get(str(name).strip().lower())
        if not field:
            warnings.append(f"field '{name}' does not exist in this list — skipped")
            continue

        kind = field.get("type")
        options = (field.get("type_config") or {}).get("options") or []
        by_name = {(opt.get("name") or "").strip().lower(): opt for opt in options}

        if kind == "drop_down":
            option = by_name.get(str(value).strip().lower())
            if not option:
                warnings.append(
                    f"field '{name}': option '{value}' not found — "
                    f"available: {', '.join(o.get('name', '') for o in options)}"
                )
                continue
            # The option UUID is accepted by both the create and the set-value
            # endpoints; orderindex is not accepted everywhere.
            payload.append({"id": field["id"], "value": option["id"]})

        elif kind == "labels":
            wanted = value if isinstance(value, list) else [value]
            ids, missing = [], []
            for item in wanted:
                option = by_name.get(str(item).strip().lower())
                (ids.append(option["id"]) if option else missing.append(str(item)))
            if missing:
                warnings.append(
                    f"field '{name}': option(s) {', '.join(missing)} not found — "
                    f"available: {', '.join(o.get('name', '') for o in options)}"
                )
            if not ids:
                continue
            payload.append({"id": field["id"], "value": ids})

        elif kind in PASSTHROUGH_NUMBER:
            try:
                payload.append({"id": field["id"], "value": float(value)})
            except (TypeError, ValueError):
                warnings.append(f"field '{name}': '{value}' is not a number — skipped")
                continue

        elif kind in PASSTHROUGH_TEXT:
            payload.append({"id": field["id"], "value": str(value)})

        elif kind == "checkbox":
            payload.append({"id": field["id"], "value": bool(value)})

        elif kind == "users":
            wanted = value if isinstance(value, list) else [value]
            payload.append({"id": field["id"], "value": {"add": [int(v) for v in wanted]}})

        else:
            warnings.append(f"field '{name}': unsupported type '{kind}' — set it in ClickUp")
            continue

        resolved.add(str(name).strip().lower())

    return payload, warnings, resolved


def find_duplicate(client: Client, list_id: str, name: str):
    """Read-only check for an existing task with the same name. First page only."""
    query = urllib.parse.urlencode({"archived": "false", "subtasks": "true"})
    status, body = client.request("GET", f"/list/{list_id}/task?{query}")
    if status != 200:
        return None, f"duplicate check skipped (HTTP {status})"
    target = name.strip().lower()
    for task in body.get("tasks", []):
        if (task.get("name") or "").strip().lower() == target:
            return task, None
    return None, None


def has_time_estimate_field(resolved_names: set) -> bool:
    """True only when a *resolved* custom field carries the time estimate."""
    return any("time estimate" in name for name in resolved_names)


def show_fields(client: Client, config: dict, requested: str) -> int:
    """Read-only: print the statuses and custom fields (with options) of one list."""
    list_id = resolve_list_id(config, requested)
    fields, error = fetch_fields(client, list_id)
    if error:
        die(3, f"API ERROR: {error}")

    status_code, list_body = client.request("GET", f"/list/{list_id}")
    statuses = (
        [item.get("status") for item in (list_body.get("statuses") or [])]
        if status_code == 200
        else [f"<unavailable: HTTP {status_code}>"]
    )

    print(json.dumps(
        {
            "list_id": list_id,
            "list_name": list_body.get("name") if status_code == 200 else None,
            "statuses": statuses,
            "fields": [
                {
                    "name": field.get("name"),
                    "type": field.get("type"),
                    "options": [
                        opt.get("name")
                        for opt in ((field.get("type_config") or {}).get("options") or [])
                    ],
                }
                for field in fields
            ],
        },
        ensure_ascii=False,
        indent=2,
    ))
    return 0


def show_lists(client: Client, config: dict) -> int:
    """Read-only: print every folder and list in the configured space, with statuses.

    `clickup.lists` in project-config.yaml only names the lists the workflow uses
    routinely; sprint lists and other folders are discovered here instead of being
    guessed.
    """
    space_id = config.get("space_id")
    if not space_id:
        die(1, "CFG ERROR: clickup.space_id is not configured")

    def statuses_of(entry: dict) -> list:
        return [item.get("status") for item in (entry.get("statuses") or [])]

    result: dict = {"space_id": space_id, "folders": [], "folderless_lists": []}

    status, body = client.request("GET", f"/space/{space_id}/folder?archived=false")
    if status != 200:
        die(3, f"API ERROR: could not read folders (HTTP {status})")
    for folder in body.get("folders", []):
        result["folders"].append({
            "folder": folder.get("name"),
            "lists": [
                {"id": lst.get("id"), "name": lst.get("name"), "statuses": statuses_of(lst)}
                for lst in (folder.get("lists") or [])
            ],
        })

    status, body = client.request("GET", f"/space/{space_id}/list?archived=false")
    if status == 200:
        result["folderless_lists"] = [
            {"id": lst.get("id"), "name": lst.get("name"), "statuses": statuses_of(lst)}
            for lst in body.get("lists", [])
        ]

    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Create one ClickUp task from a payload file.")
    parser.add_argument("--payload", help="path to the payload JSON file")
    parser.add_argument("--dry-run", action="store_true", help="resolve everything, create nothing")
    parser.add_argument("--allow-duplicate", action="store_true", help="permit an existing same-name task")
    parser.add_argument(
        "--show-fields",
        metavar="LIST",
        help="read-only: list the custom fields of a list (a clickup.lists key, 'test', or an id) and exit",
    )
    parser.add_argument(
        "--show-lists",
        action="store_true",
        help="read-only: list every folder and list in the configured space, with statuses, and exit",
    )
    args = parser.parse_args(argv[1:])

    if args.show_lists:
        config = load_clickup_config()
        client, _ = authenticate()
        return show_lists(client, config)

    if args.show_fields:
        config = load_clickup_config()
        client, _ = authenticate()
        return show_fields(client, config, args.show_fields)

    if not args.payload:
        die(1, "usage: --payload <file.json> (or --show-fields <list>)")
    if not os.path.isfile(args.payload):
        die(1, f"PAYLOAD ERROR: {args.payload} not found")
    try:
        with open(args.payload, encoding="utf-8") as handle:
            payload = json.load(handle)
    except json.JSONDecodeError as exc:
        die(1, f"PAYLOAD ERROR: not valid JSON: {exc}")

    name = (payload.get("name") or "").strip()
    markdown = payload.get("markdown") or ""
    if not name:
        die(1, "PAYLOAD ERROR: `name` is required")
    if not markdown.strip():
        die(1, "PAYLOAD ERROR: `markdown` (the ticket body) is required")

    config = load_clickup_config()
    client, _ = authenticate()
    list_id = resolve_list_id(config, payload.get("list"))

    assignees = payload.get("assignees")
    if assignees is None and config.get("default_assignee"):
        assignees = [int(config["default_assignee"])]
    tags = payload.get("tags")
    if tags is None and config.get("default_tag"):
        tags = [config["default_tag"]]

    requested_fields = payload.get("fields") or {}
    custom_fields, warnings, resolved_fields = build_custom_fields(client, list_id, requested_fields)

    body: dict = {
        "name": name,
        # `markdown_content` renders the body; `description` is sent too so the
        # text still lands if the workspace ignores the markdown key.
        "markdown_content": markdown,
        "description": markdown,
    }
    if payload.get("status"):
        body["status"] = payload["status"]
    if assignees:
        body["assignees"] = [int(a) for a in assignees]
    if tags:
        body["tags"] = list(tags)
    if custom_fields:
        body["custom_fields"] = custom_fields

    hours = payload.get("time_estimate_hours")
    if hours and not has_time_estimate_field(resolved_fields):
        # No "Time Estimate" custom field actually resolved — a requested-but-missing
        # one must not swallow the estimate, so fall back to the built-in field (ms).
        body["time_estimate"] = int(float(hours) * 3600 * 1000)

    duplicate, dup_warning = find_duplicate(client, list_id, name)
    if dup_warning:
        warnings.append(dup_warning)
    if duplicate and not args.allow_duplicate:
        die(
            4,
            f"DUPLICATE ERROR: list {list_id} already has a task named '{name}' "
            f"({duplicate.get('url')}) — pass --allow-duplicate to create it anyway",
        )

    for warning in warnings:
        print(f"warning: {warning}", file=sys.stderr)

    if args.dry_run:
        preview = dict(body)
        preview["markdown_content"] = f"<{len(markdown)} chars>"
        preview["description"] = f"<{len(markdown)} chars>"
        print(json.dumps(
            {
                "dry_run": True,
                "list_id": list_id,
                "would_post": preview,
                "resolved_custom_fields": len(custom_fields),
                "warnings": warnings,
            },
            ensure_ascii=False,
            indent=2,
        ))
        return 0

    status, created = client.request("POST", f"/list/{list_id}/task", body)
    if status not in (200, 201):
        die(3, f"API ERROR: create task failed (HTTP {status}): {json.dumps(created)[:400]}")

    print(json.dumps(
        {
            "id": created.get("id"),
            "url": created.get("url"),
            "name": created.get("name"),
            "list_id": list_id,
            "warnings": warnings,
        },
        ensure_ascii=False,
        indent=2,
    ))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
