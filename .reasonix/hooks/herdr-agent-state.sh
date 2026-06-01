#!/bin/sh
# Reasonix → herdr agent state reporter.
# Hand-rolled mirror of herdr's official claude integration hook.
# Reasonix has no built-in herdr integration (`herdr integration install`
# does not list reasonix), so this lives in dotfiles and is wired up by
# ~/.reasonix/settings.json.
#
# Lifecycle mapping (reasonix has fewer events than claude):
#   UserPromptSubmit / PreToolUse  → working
#   Stop                           → idle
#   (PostToolUse not used: redundant with PreToolUse for state tracking)

set -eu

action="${1:-}"
hook_input_file="$(mktemp "${TMPDIR:-/tmp}/herdr-reasonix-hook.XXXXXX")" || exit 0
trap 'rm -f "$hook_input_file"' EXIT HUP INT TERM
cat >"$hook_input_file" 2>/dev/null || true

case "$action" in
  working|idle|blocked|release) ;;
  *) exit 0 ;;
esac

[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_SOCKET_PATH:-}" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

HERDR_ACTION="$action" python3 - <<'PY'
import json
import os
import random
import socket
import time

source = "custom:reasonix"
agent_name = "reasonix"
action = os.environ.get("HERDR_ACTION", "")
pane_id = os.environ.get("HERDR_PANE_ID")
socket_path = os.environ.get("HERDR_SOCKET_PATH")

if not pane_id or not socket_path:
    raise SystemExit(0)

request_id = f"{source}:{int(time.time() * 1000)}:{random.randrange(1_000_000):06d}"
report_seq = time.time_ns()

if action == "release":
    request = {
        "id": request_id,
        "method": "pane.release_agent",
        "params": {
            "pane_id": pane_id,
            "source": source,
            "agent": agent_name,
            "seq": report_seq,
        },
    }
else:
    request = {
        "id": request_id,
        "method": "pane.report_agent",
        "params": {
            "pane_id": pane_id,
            "source": source,
            "agent": agent_name,
            "state": action,
            "seq": report_seq,
        },
    }

try:
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(2.0)
    sock.connect(socket_path)
    sock.sendall((json.dumps(request) + "\n").encode("utf-8"))
    # Drain a small response to keep server happy; ignore content.
    try:
        sock.recv(4096)
    except Exception:
        pass
    sock.close()
except Exception:
    raise SystemExit(0)
PY
