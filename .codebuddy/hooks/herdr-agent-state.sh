#!/bin/sh
# CodeBuddy → herdr agent state reporter (dotfiles-managed).
#
# Modeled on herdr's official claude integration v4, with two differences:
#   1. Reports agent="codebuddy" (not "claude") so herdr's sidebar shows
#      the right label. CodeBuddy is a Claude fork but it's a distinct
#      product to surface separately.
#   2. Reports agent="codebuddy" (not "claude") so herdr's sidebar shows
#      the right label. Stop maps to "idle" (consistent with other agents).
#
# Lifecycle map:
#   SessionStart       → idle     (fresh session, no work yet)
#   UserPromptSubmit   → working  (user just submitted)
#   PreToolUse         → working  (about to call a tool)
#   PostToolUse        → working  (tool returned, more may follow)
#   PermissionRequest  → blocked  (asking user to allow a tool)
#   Stop               → idle     (turn ended, waiting for next prompt)
#   SubagentStop       → ignore   (subagent done; parent may still be working)
#   SessionEnd         → release  (clear agent label from herdr)
#
# Non-interactive caveat: in print mode (`codebuddy -p`), the process exits
# right after Stop and SessionEnd never fires, so the pane would keep a stale
# "codebuddy" label stuck at idle. To handle that, the Stop branch detects
# whether the owning CodeBuddy process is running in print mode and, if so,
# upgrades idle → release (the process is about to exit anyway).
#
# Triggered from ~/.codebuddy/settings.json hooks block. Every action
# branch reads stdin to drain the hook payload (CodeBuddy writes JSON to
# stdin and waits for the hook to read it).

set -eu

action="${1:-}"
hook_input_file="$(mktemp "${TMPDIR:-/tmp}/herdr-codebuddy-hook.XXXXXX")" || exit 0
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

HERDR_ACTION="$action" HERDR_HOOK_INPUT_FILE="$hook_input_file" python3 - <<'PY'
import json
import os
import random
import socket
import subprocess
import time

source = "custom:codebuddy"
agent_name = "codebuddy"
action = os.environ.get("HERDR_ACTION", "")
pane_id = os.environ.get("HERDR_PANE_ID")
socket_path = os.environ.get("HERDR_SOCKET_PATH")
hook_input_file = os.environ.get("HERDR_HOOK_INPUT_FILE")

if not pane_id or not socket_path:
    raise SystemExit(0)


def _ps(pid, field):
    try:
        out = subprocess.run(
            ["ps", "-o", field + "=", "-p", str(pid)],
            capture_output=True,
            text=True,
            timeout=1.0,
        )
        return out.stdout.strip()
    except Exception:
        return ""


def owning_codebuddy_in_print_mode():
    # Walk up the process tree from this hook. CodeBuddy launches hooks via a
    # short-lived shell, whose parent is the long-lived node CodeBuddy process.
    # In print mode that process's argv contains -p / --print. If we find it,
    # the session will exit without ever firing SessionEnd.
    pid = os.getppid()
    for _ in range(8):
        if not pid or pid <= 1:
            break
        cmd = _ps(pid, "command")
        if ("node" in cmd or "codebuddy" in cmd or "/cbc" in cmd) and (
            "codebuddy" in cmd or "cbc" in cmd
        ):
            args = cmd.split()
            if "-p" in args or "--print" in args:
                return True
        ppid = _ps(pid, "ppid")
        if not ppid.isdigit():
            break
        pid = int(ppid)
    return False

hook_input = {}
if hook_input_file:
    try:
        with open(hook_input_file, encoding="utf-8") as handle:
            content = handle.read()
        if content.strip():
            hook_input = json.loads(content)
    except Exception:
        hook_input = {}

# SubagentStop fires when a teammate/subagent finishes. The parent main
# session may still be working — never let SubagentStop revive an idle
# pane or downgrade a working one.
hook_event_name = str(hook_input.get("hook_event_name") or "")
is_subagent = bool(hook_input.get("agent_id"))
if hook_event_name == "SubagentStop":
    raise SystemExit(0)
if is_subagent and action in ("idle", "release"):
    raise SystemExit(0)

# In print mode (`codebuddy -p`) the process exits right after Stop and never
# emits SessionEnd, so a plain "idle" report would leave the pane labelled
# forever. Upgrade the Stop → idle into a release so the label is cleared as
# the session ends. Scope this strictly to the Stop event (SessionStart also
# maps to idle, but the process is not exiting then).
if (
    action == "idle"
    and hook_event_name == "Stop"
    and not is_subagent
    and owning_codebuddy_in_print_mode()
):
    action = "release"

request_id = f"{source}:{int(time.time() * 1000)}:{random.randrange(1_000_000):06d}"
report_seq = time.time_ns()
session_id = hook_input.get("session_id")
agent_session_id = session_id if isinstance(session_id, str) and session_id else None
transcript_path = hook_input.get("transcript_path")
agent_session_path = transcript_path if isinstance(transcript_path, str) and transcript_path else None
session_start_source = hook_input.get("source") if hook_event_name == "SessionStart" else None
if not isinstance(session_start_source, str) or not session_start_source:
    session_start_source = None

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
    params = {
        "pane_id": pane_id,
        "source": source,
        "agent": agent_name,
        "state": action,
        "seq": report_seq,
    }
    if agent_session_id:
        params["agent_session_id"] = agent_session_id
    if agent_session_path:
        params["agent_session_path"] = agent_session_path
    if session_start_source:
        params["session_start_source"] = session_start_source
    request = {"id": request_id, "method": "pane.report_agent", "params": params}

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
