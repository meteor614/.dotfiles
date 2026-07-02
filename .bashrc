# ~/.bashrc — bash-specific bits only; shared logic lives in
# $XDG_CONFIG_HOME/shell/common.sh (sourced below).

# Bash prompt (Starship is started from common.sh)
export PS1='[\u@\h \w]$ '

# -----------------------------------------------------------------------------
# Shared config (aliases, TERM, NVM lazy loader, Homebrew mirror, …)
# NOTE: This path resolution is duplicated in .zshrc because bash has no
# equivalent of .zshenv for early shared init. Keep both in sync.
# -----------------------------------------------------------------------------
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
_common_sh="$XDG_CONFIG_HOME/shell/common.sh"
[ ! -f "$_common_sh" ] && [ -f "$HOME/.dotfiles/.config/shell/common.sh" ] \
    && _common_sh="$HOME/.dotfiles/.config/shell/common.sh"
# shellcheck source=/dev/null
[ -f "$_common_sh" ] && . "$_common_sh"
unset _common_sh

# Prepend $HOME/bin AFTER common.sh so it takes priority over atuin/nvm
if command -v path_force_prepend >/dev/null 2>&1; then
    path_force_prepend "$HOME/bin"
elif [ -d "$HOME/bin" ]; then
    case ":$PATH:" in *":$HOME/bin:"*) ;; *) export PATH="$HOME/bin:$PATH" ;; esac
fi

# -----------------------------------------------------------------------------
# Extras that require bash-specific features / hooks
# -----------------------------------------------------------------------------
[ -f ~/.fzf.bash ] && . ~/.fzf.bash

# kubectl completion: generate once and cache, regenerate when the binary
# changes. Avoids forking kubectl on every interactive shell startup.
if command -v kubectl >/dev/null 2>&1; then
    _kubectl_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/kubectl.bash"
    if [ ! -f "$_kubectl_cache" ] || [ "$(command -v kubectl)" -nt "$_kubectl_cache" ]; then
        mkdir -p "$(dirname "$_kubectl_cache")"
        kubectl completion bash >| "$_kubectl_cache" 2>/dev/null || rm -f "$_kubectl_cache"
    fi
    [ -s "$_kubectl_cache" ] && . "$_kubectl_cache"
    unset _kubectl_cache
fi

# perlbrew
[ -f ~/perl5/perlbrew/etc/bashrc ] && . ~/perl5/perlbrew/etc/bashrc

# atuin (needs bash-preexec in bash; skip in non-interactive shells)
if [[ $- == *i* ]] && command -v atuin >/dev/null 2>&1; then
    [ -f ~/.bash-preexec.sh ] && . ~/.bash-preexec.sh
    _atuin_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/atuin.bash"
    if [ ! -f "$_atuin_cache" ] || [ "$(command -v atuin)" -nt "$_atuin_cache" ]; then
        mkdir -p "$(dirname "$_atuin_cache")"
        atuin init bash >| "$_atuin_cache" 2>/dev/null || rm -f "$_atuin_cache"
    fi
    [ -s "$_atuin_cache" ] && . "$_atuin_cache"
    unset _atuin_cache
fi

# auto-venv: wire up via PROMPT_COMMAND (common.sh has already sourced the file)
if [ -n "${AUTO_VENV_HELPER:-}" ] && [ -f "$AUTO_VENV_HELPER" ]; then
    _auto_venv_refresh
    case ";$PROMPT_COMMAND;" in
        *";_auto_venv_refresh;"*) ;;
        *)
            if [ -n "$PROMPT_COMMAND" ]; then
                PROMPT_COMMAND="_auto_venv_refresh;$PROMPT_COMMAND"
            else
                PROMPT_COMMAND="_auto_venv_refresh"
            fi
            ;;
    esac
fi
unset AUTO_VENV_HELPER

# Multiplexer user-var emitter (tells WezTerm/Ghostty about inner tmux/zellij)
case ";$PROMPT_COMMAND;" in
    *";_emit_mux_user_var;"*) ;;
    *)
        if [ -n "$PROMPT_COMMAND" ]; then
            PROMPT_COMMAND="_emit_mux_user_var;$PROMPT_COMMAND"
        else
            PROMPT_COMMAND="_emit_mux_user_var"
        fi
        ;;
esac

# zoxide
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# Local machine-specific overrides
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
