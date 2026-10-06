# ~/.bashrc — bash-specific bits only; shared logic lives in
# $XDG_CONFIG_HOME/shell/common.sh (sourced below).

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

# Bash prompt fallback; Starship (when present) is initialized from common.sh.
if ! command -v starship >/dev/null 2>&1; then
    export PS1='[\u@\h \w]$ '
fi

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

# kubectl completion: lazy wrapper aligned with the zsh side (.zshrc.local) —
# the ~30KB generated script is only sourced on first use, and the cache is
# regenerated when the binary changes.
if command -v kubectl >/dev/null 2>&1; then
    kubectl() {
        unset -f kubectl
        dotfiles_cached_eval kubectl "$(command -v kubectl)" bash completion bash
        command kubectl "$@"
    }
fi

# perlbrew
[ -f ~/perl5/perlbrew/etc/bashrc ] && . ~/perl5/perlbrew/etc/bashrc

# atuin (needs bash-preexec in bash; skip in non-interactive shells)
if [[ $- == *i* ]] && command -v atuin >/dev/null 2>&1; then
    [ -f ~/.bash-preexec.sh ] && . ~/.bash-preexec.sh
    dotfiles_cached_eval atuin "$(command -v atuin)" bash init bash
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

# OSC 133 command marks (tuios run/wait-for needs A/B/C/D; see common.sh)
if [[ $- == *i* ]]; then
    # bash has no native preexec, so the C mark depends on bash-preexec, whose
    # public arrays are preexec_functions / precmd_functions. atuin vendors one
    # and registers through it; honour a standalone ~/.bash-preexec.sh too, so
    # the marks do not quietly depend on atuin being installed.
    if ! declare -p preexec_functions >/dev/null 2>&1 \
        && [ -f "$HOME/.bash-preexec.sh" ]; then
        # shellcheck source=/dev/null
        . "$HOME/.bash-preexec.sh"
    fi

    # First in PROMPT_COMMAND, so $? is still the previous command's status.
    case ";$PROMPT_COMMAND;" in
        *";_emit_osc133_precmd;"*) ;;
        *)
            if [ -n "$PROMPT_COMMAND" ]; then
                PROMPT_COMMAND="_emit_osc133_precmd;$PROMPT_COMMAND"
            else
                PROMPT_COMMAND="_emit_osc133_precmd"
            fi
            ;;
    esac

    if declare -p preexec_functions >/dev/null 2>&1; then
        case ";${preexec_functions[*]};" in
            *";_emit_osc133_preexec;"*) ;;
            *) preexec_functions+=(_emit_osc133_preexec) ;;
        esac
    fi

    # Last in PROMPT_COMMAND, so the B chunk lands after starship has assigned
    # this prompt's PS1.
    case ";$PROMPT_COMMAND;" in
        *";_emit_osc133_prompt_tail;"*) ;;
        *)
            if [ -n "$PROMPT_COMMAND" ]; then
                PROMPT_COMMAND="$PROMPT_COMMAND;_emit_osc133_prompt_tail"
            else
                PROMPT_COMMAND="_emit_osc133_prompt_tail"
            fi
            ;;
    esac
fi

# zoxide (cached to avoid fork on every shell startup)
if command -v zoxide >/dev/null 2>&1; then
    dotfiles_cached_eval zoxide "$(command -v zoxide)" bash init bash
fi

# Local machine-specific overrides
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
