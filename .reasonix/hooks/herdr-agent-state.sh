#!/bin/sh
# Reasonix → herdr agent state reporter.
#
# Lifecycle (reasonix 0.53 fires PreToolUse and PostToolUse only):
#
#   PreToolUse (before each tool call)
#     ├─ ① detect tool name from stdin → blocked if edit_file/write_file, else working
#     └─ ② cancel any pending deferred-idle (background process)
#
#   PostToolUse (after each tool call)
#     └─ ③ schedule deferred-idle: sleep 3s, then send idle if no new
#          working arrived → stays working during multi-tool turns
#
#   Shell wrapper (on reasonix exit)
#     └─ ④ release → kill pending idle, clear agent label from herdr

set -eu

action="${1:-}"

# --- internal actions: sent via "$0" from background / wrapper ---
case "$action" in
  working|idle|blocked|release|_send_idle) ;;
  *) exit 0 ;;
esac

[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_SOCKET_PATH:-}" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

STATE_DIR="${HOME}/.reasonix/hooks"
LAST_ACTIVE="${STATE_DIR}/.last-active"
IDLE_PID_FILE="${STATE_DIR}/.idle-pending.pid"
IDLE_COOLDOWN="${HERDR_IDLE_COOLDOWN_SECS:-3}"

# --- helper: cancel a previously scheduled deferred idle ---
_cancel_pending_idle() {
    if [ -f "$IDLE_PID_FILE" ]; then
        old_pid="$(cat "$IDLE_PID_FILE" 2>/dev/null || echo "")"
        [ -n "$old_pid" ] && kill "$old_pid" 2>/dev/null || true
        rm -f "$IDLE_PID_FILE"
    fi
}

# --- helper: send report to herdr socket ---
_send() {
    local state="$1"
    HERDR_ACTION="$state" python3 - <<'PY'
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
}

# =============================================================================
#  Action handlers
# =============================================================================

# --- _send_idle: deferred idle fire from background process ---
if [ "$action" = "_send_idle" ]; then
    # Re-check: another working might have snuck in while we were sleeping
    if [ -f "$LAST_ACTIVE" ]; then
        now=$(date +%s)
        last=$(date -r "$LAST_ACTIVE" +%s 2>/dev/null || echo 0)
        elapsed=$(( now - last ))
        if [ "$elapsed" -lt "$IDLE_COOLDOWN" ]; then
            rm -f "$IDLE_PID_FILE"
            exit 0
        fi
    fi
    _send "idle"
    rm -f "$IDLE_PID_FILE"
    exit 0
fi

# --- release: clear agent label on reasonix exit ---
if [ "$action" = "release" ]; then
    _cancel_pending_idle
    _send "release"
    exit 0
fi

# --- working / idle / blocked ---

case "$action" in
  working)
    mkdir -p "$STATE_DIR"
    touch "$LAST_ACTIVE"
    _cancel_pending_idle

    # --- detect tool from stdin: edit_file / write_file → blocked ---
    # Dump stdin to a fixed path so we can inspect the format
    cat 2>/dev/null >"${STATE_DIR}/.last-stdin" || true
    tool_json="$(cat "${STATE_DIR}/.last-stdin" 2>/dev/null || true)"

    block_state=""
    if [ -n "$tool_json" ]; then
        case "$tool_json" in
          *'"toolName":"edit_file"'*|*'"toolName":"multi_edit"'*|*'"toolName":"write_file"'*)
            block_state="blocked"
            ;;
        esac
    fi

    if [ -n "$block_state" ]; then
        _send "blocked"
    else
        _send "working"
    fi
    ;;

  idle)
    # Don't send idle immediately. Schedule a background process that
    # sends idle after IDLE_COOLDOWN seconds, unless cancelled by a
    # new PreToolUse (working).
    _cancel_pending_idle

    (
        sleep "$IDLE_COOLDOWN"
        exec bash "$0" "_send_idle" </dev/null >/dev/null 2>&1
    ) &
    echo $! > "$IDLE_PID_FILE"
    ;;

  blocked)
    _send "blocked"
    ;;
esac
