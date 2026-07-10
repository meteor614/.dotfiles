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
    [ "${VIRTUAL_ENV:-}" = "$AUTO_VENV_PATH" ]
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

    # VIRTUAL_ENV is set. If it does not match the .venv we would activate
    # for the current directory, treat it as a stale/inherited env (e.g. from
    # a tmux/herdr server process) and allow auto-venv to take over.
    if [ -n "$target_venv" ] && [ "$VIRTUAL_ENV" != "$target_venv" ]; then
        return 1
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
