# ~/.bashrc — bash-specific bits only; shared logic lives in
# $XDG_CONFIG_HOME/shell/common.sh (sourced below).

# Bash prompt (Starship is started from common.sh)
export PS1='[\u@\h \w]$ '

# -----------------------------------------------------------------------------
# PATH (bash-friendly: no zsh-only operators)
# -----------------------------------------------------------------------------
_bash_path_prepend() {
    [ -n "$1" ] && [ -d "$1" ] && case ":$PATH:" in
        *":$1:"*) ;;
        *) export PATH="$1:$PATH" ;;
    esac
}
_bash_path_append() {
    [ -n "$1" ] && [ -d "$1" ] && case ":$PATH:" in
        *":$1:"*) ;;
        *) export PATH="$PATH:$1" ;;
    esac
}

# Synology Entware & common extra paths (highest priority first = prepended last)
_bash_path_prepend /opt/usr/bin
_bash_path_prepend /opt/bin
_bash_path_prepend /opt/sbin
_bash_path_prepend /opt/homebrew/bin
_bash_path_prepend /usr/local/bin
_bash_path_prepend /usr/local/opt/findutils/libexec/gnubin
_bash_path_prepend /usr/local/opt/gnu-getopt/bin
_bash_path_prepend /usr/local/opt/ruby/bin
_bash_path_append  "$HOME/bin"
_bash_path_append  "$HOME/.local/bin"

# -----------------------------------------------------------------------------
# Shared config (aliases, TERM, NVM lazy loader, Homebrew mirror, …)
# -----------------------------------------------------------------------------
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
_common_sh="$XDG_CONFIG_HOME/shell/common.sh"
[ ! -f "$_common_sh" ] && [ -f "$HOME/.dotfiles/.config/shell/common.sh" ] \
    && _common_sh="$HOME/.dotfiles/.config/shell/common.sh"
# shellcheck source=/dev/null
[ -f "$_common_sh" ] && . "$_common_sh"
unset _common_sh

# -----------------------------------------------------------------------------
# Go
# -----------------------------------------------------------------------------
if command -v go >/dev/null 2>&1 && [ -z "$GOPATH" ]; then
    export GOPATH="$HOME/gowork"
    _bash_path_append "$GOPATH/bin"
    _bash_path_append /usr/local/opt/go/libexec/bin
    export GOPROXY=https://mirrors.tencent.com/go/
fi

# -----------------------------------------------------------------------------
# Extras that require bash-specific features / hooks
# -----------------------------------------------------------------------------
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"
[ -f ~/.fzf.bash ] && . ~/.fzf.bash
command -v kubectl >/dev/null 2>&1 && . <(kubectl completion bash)
[ -e "$HOME/.iterm2_shell_integration.zsh" ] && . "$HOME/.iterm2_shell_integration.zsh"

# perlbrew
[ -f ~/perl5/perlbrew/etc/bashrc ] && . ~/perl5/perlbrew/etc/bashrc

# atuin (needs bash-preexec in bash)
if command -v atuin >/dev/null 2>&1; then
    [ -f ~/.bash-preexec.sh ] && . ~/.bash-preexec.sh
    eval "$(atuin init bash)"
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

unset -f _bash_path_prepend _bash_path_append
