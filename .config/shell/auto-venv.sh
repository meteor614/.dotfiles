# Auto-activate the nearest ancestor `.venv` without overriding manual envs.

_auto_venv_clear_state() {
    unset AUTO_VENV_ACTIVE AUTO_VENV_PATH
}

_auto_venv_find() {
    local dir
    dir="${PWD:-}"
    [ -n "$dir" ] || return 1

    while :; do
        if [ -f "$dir/.venv/bin/activate" ]; then
            printf '%s\n' "$dir/.venv"
            return 0
        fi

        [ "$dir" = "/" ] && break
        dir="${dir%/*}"
        [ -n "$dir" ] || dir="/"
    done

    return 1
}

_auto_venv_is_current() {
    [ "${AUTO_VENV_ACTIVE:-}" = "1" ] || return 1
    [ -n "${AUTO_VENV_PATH:-}" ] || return 1
    [ "${VIRTUAL_ENV:-}" = "$AUTO_VENV_PATH" ] || return 1

    # Make sure the venv's bin dir is actually at the front of PATH. Other
    # tools (e.g. mise) may prepend themselves after the venv was activated,
    # especially in restored multiplexer sessions where the env is inherited.
    case ":${PATH:-}:" in
        ":$AUTO_VENV_PATH/bin:"*) return 0 ;;
        *) return 1 ;;
    esac
}

_auto_venv_external_env_active() {
    local target_venv="${1:-}"

    _auto_venv_is_current && return 1

    [ -n "${VIRTUAL_ENV:-}" ] || {
        if [ "${CONDA_SHLVL:-0}" -gt 0 ] 2>/dev/null; then
            return 0
        fi
        return 1
    }

    # If VIRTUAL_ENV points to a different .venv, treat it as a stale/inherited
    # env (e.g. from a tmux/herdr server process) and allow auto-venv to take over.
    if [ -n "$target_venv" ] && [ "$VIRTUAL_ENV" != "$target_venv" ]; then
        return 1
    fi

    # VIRTUAL_ENV matches the target. Only block if PATH already has the venv
    # bin dir at the front; otherwise let auto-venv re-activate to fix PATH.
    if [ -n "$target_venv" ]; then
        case ":${PATH:-}:" in
            ":$target_venv/bin:"*) return 0 ;;
            *) return 1 ;;
        esac
    fi

    return 0
}

_auto_venv_deactivate() {
    _auto_venv_is_current || {
        _auto_venv_clear_state
        return 0
    }

    if type deactivate >/dev/null 2>&1; then
        deactivate >/dev/null 2>&1
    fi

    _auto_venv_clear_state
}

_auto_venv_restore() {
    # Restore PATH to its pre-auto-venv state right before forking a
    # long-lived subprocess (agent CLI). Auto-venv activates a project .venv
    # by prepending its bin dir to PATH; an agent forked in that window
    # inherits the venv's `python3` (e.g. a 3.11 venv without PyYAML) and
    # breaks unrelated scripts that rely on the system/mise python. Callers
    # (e.g. the reasonix wrapper in common.sh) invoke this before spawning.
    #
    # Must not rely on _auto_venv_deactivate/VIRTUAL_ENV: in the real leak
    # (herdr pane restore) the venv's bin dir is left in PATH but the
    # AUTO_VENV_* / VIRTUAL_ENV state is already gone, so deactivate is a
    # no-op. Strip any known .venv bin dir directly from PATH instead.
    local _av_entry _av_out="" _av_seen_venv=0
    case ":${PATH}:" in
        *:*/\.venv/bin:*) _av_seen_venv=1 ;;
    esac
    [ "$_av_seen_venv" -eq 1 ] || return 0

    while [ -n "$PATH" ]; do
        case "$PATH" in
            *:*)
                _av_entry=${PATH%%:*}
                PATH=${PATH#*:}
                ;;
            *)
                _av_entry=$PATH
                PATH=
                ;;
        esac
        case "$_av_entry" in
            */\.venv/bin) ;;
            *) _av_out="${_av_out}${_av_out:+:}${_av_entry}" ;;
        esac
    done
    PATH=$_av_out
    export PATH
    unset _av_entry _av_out _av_seen_venv
}

_auto_venv_activate() {
    local venv_path
    venv_path="$1"

    [ -n "$venv_path" ] || return 1

    if _auto_venv_is_current && [ "${VIRTUAL_ENV:-}" = "$venv_path" ]; then
        return 0
    fi

    _auto_venv_deactivate
    _auto_venv_external_env_active "$venv_path" && return 0

    [ -f "$venv_path/bin/activate" ] || return 1

    . "$venv_path/bin/activate"

    AUTO_VENV_ACTIVE=1
    AUTO_VENV_PATH="$venv_path"
    export AUTO_VENV_ACTIVE AUTO_VENV_PATH
}

_auto_venv_refresh() {
    local venv_path=""

    # Guard: only (re)activate a venv in interactive shells. Agent CLIs
    # (reasonix/claude/codex/...) and scripts are forked from a shell whose
    # PATH may briefly carry a project .venv during a herdr/tmux pane restore;
    # if they fork in that window they inherit the venv's `python3` (e.g. a
    # 3.11 venv without PyYAML) and break unrelated scripts. Restricting
    # auto-activation to interactive shells keeps the venv scoped to the
    # user's own prompt and out of non-interactive subprocesses.
    case $- in
        *i*) ;;
        *) return 0 ;;
    esac

    # Avoid repeated work when hooked to precmd/PROMPT_COMMAND and PWD
    # has not changed since the last run.
    if [ "${AUTO_VENV_LAST_PWD:-}" = "${PWD:-}" ]; then
        return 0
    fi
    AUTO_VENV_LAST_PWD="${PWD:-}"

    if [ "${AUTO_VENV_ACTIVE:-}" = "1" ] && ! _auto_venv_is_current; then
        _auto_venv_clear_state
    fi

    venv_path="$(_auto_venv_find 2>/dev/null)" || venv_path=""

    if [ -n "$venv_path" ]; then
        if _auto_venv_is_current && [ "${VIRTUAL_ENV:-}" = "$venv_path" ]; then
            return 0
        fi

        _auto_venv_external_env_active "$venv_path" && return 0
        _auto_venv_activate "$venv_path"
        return 0
    fi

    _auto_venv_deactivate
}
