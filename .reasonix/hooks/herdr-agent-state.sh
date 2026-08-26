#!/bin/sh
# Reasonix → herdr agent state reporter.
#
# Verified against reasonix v1.31.4 + herdr 0.8.2.
#
# Hook wiring lives in ~/.reasonix/settings.json ("hooks"); lifecycle:
#
#   SessionStart       → idle      (also binds the herdr session, see below)
#   UserPromptSubmit   → working   (turn starts, agent is busy)
#   Notification       → blocked   (approval dialog is waiting)
#   PreToolUse         → blocked   (match: delete_range|delete_symbol|edit_file|
#                                   move_file|multi_edit|notebook_edit|
#                                   write_file — agent waits for approval)
#   PostToolUse        → working   (restores working after each tool call)
#   Stop               → idle      (turn truly ended)
#   SessionEnd         → release   (clears the agent label from herdr)
#
# Since herdr 0.8.x, official integrations also bind the logical conversation
# to the pane via pane.report_agent_session (agent_session_id) so that state
# can be correlated per session instead of per pane only. This reporter reads
# the hook's JSON payload from stdin on a best-effort basis:
#
#   - a SessionStart payload carrying a session id additionally sends one
#     pane.report_agent_session bind before reporting the state;
#   - every other action carries the session id (when known) inside its
#     pane.report_agent params;
#   - without a payload / session id it degrades to plain pane-level
#     reporting (the pre-binding behavior).
#
# No deferred-idle cooldown hack, no background processes, no state files.

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
import json, os, random, re, socket, sys, time

source = "custom:reasonix"
agent_name = "reasonix"
pane_id = os.environ.get("HERDR_PANE_ID")
socket_path = os.environ.get("HERDR_SOCKET_PATH")
action = os.environ.get("HERDR_ACTION", "")

if not pane_id or not socket_path:
    raise SystemExit(0)

def read_session_id():
    """Best-effort session id extraction from the hook stdin payload.

    reasonix passes a JSON object on stdin; tolerate non-JSON or missing
    input and fall back to pane-only reporting."""
    try:
        if sys.stdin.isatty():
            return None
        raw = sys.stdin.read()
    except Exception:
        return None
    if not raw or not raw.strip():
        return None
    # Scan rather than parse: hooks may prepend log lines before the JSON.
    for candidate in re.findall(r'\{.*\}', raw, re.S):
        try:
            data = json.loads(candidate)
        except Exception:
            continue
        if isinstance(data, dict):
            value = data.get("session_id") or data.get("sessionId") \
                or (data.get("payload") or {}).get("session_id")
            if isinstance(value, str) and value.strip():
                return value.strip()
            break
    return None

request_id = f"{source}:{int(time.time() * 1000)}:{random.randrange(1_000_000):06d}"
report_seq = time.time_ns()
session_id = read_session_id()

requests = []

if action == "release":
    params = {"pane_id": pane_id, "source": source, "agent": agent_name, "seq": report_seq}
    requests.append({"id": request_id, "method": "pane.release_agent", "params": params})
else:
    # Bind the logical session once at session start so herdr correlates
    # state reports with this conversation across pane reuse.
    if action == "idle" and session_id:
        requests.append({
            "id": request_id + ":s",
            "method": "pane.report_agent_session",
            "params": {
                "pane_id": pane_id,
                "source": source,
                "agent": agent_name,
                "seq": report_seq,
                "agent_session_id": session_id,
                "session_start_source": "startup",
            },
        })
    params = {"pane_id": pane_id, "source": source, "agent": agent_name, "state": action, "seq": report_seq}
    if session_id:
        params["agent_session_id"] = session_id
    requests.append({"id": request_id, "method": "pane.report_agent", "params": params})

try:
    for request in requests:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(0.5)
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
