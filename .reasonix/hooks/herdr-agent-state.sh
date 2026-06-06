#!/bin/sh
# Reasonix → herdr agent state reporter.
#
# Lifecycle (reasonix 1.2.0+):
#
#   UserPromptSubmit (user submits a prompt)
#     └─ working — turn starts, agent is busy
#
#   PreToolUse (before each tool call — match: edit_file|write_file|multi_edit)
#     └─ blocked — agent is waiting for user approval on a file write
#
#   Stop (turn truly ended — new in 1.2.0, the missing signal from 0.53)
#     └─ idle — turn done, agent is back to idle
#
#   Shell wrapper (on reasonix exit)
#     └─ release → clear agent label from herdr
#
# Compared to the 0.53 version: no more deferred-idle cooldown hack, no
# stdin-based tool-name detection (1.2.0's match filter handles that),
# no background processes or state files.

set -eu

action="${1:-}"

case "$action" in
  working|idle|blocked|release) ;;
  *) exit 0 ;;
esac

[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_SOCKET_PATH:-}" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

HERDR_ACTION="$action" python3 - <<'PY'
import json, os, random, socket, time

source = "custom:reasonix"
agent_name = "reasonix"
pane_id = os.environ.get("HERDR_PANE_ID")
socket_path = os.environ.get("HERDR_SOCKET_PATH")
action = os.environ.get("HERDR_ACTION", "")

if not pane_id or not socket_path:
    raise SystemExit(0)

request_id = f"{source}:{int(time.time() * 1000)}:{random.randrange(1_000_000):06d}"
report_seq = time.time_ns()

if action == "release":
    request = {
        "id": request_id,
        "method": "pane.release_agent",
        "params": {"pane_id": pane_id, "source": source, "agent": agent_name, "seq": report_seq},
    }
else:
    request = {
        "id": request_id,
        "method": "pane.report_agent",
        "params": {"pane_id": pane_id, "source": source, "agent": agent_name, "state": action, "seq": report_seq},
    }

try:
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(2.0)
    sock.connect(socket_path)
    sock.sendall((json.dumps(request) + "\n").encode("utf-8"))
    try:
        sock.recv(4096)
    except Exception:
        pass
    sock.close()
except Exception:
    raise SystemExit(0)
PY
