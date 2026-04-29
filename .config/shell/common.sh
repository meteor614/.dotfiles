# =============================================================================
# Shared shell configuration for bash + zsh
# Sourced from ~/.bashrc and ~/.zshrc (and ~/.zshrc.local for some bits).
# Keep this file POSIX-ish (works in bash 3.2+ and recent zsh). No array
# parameter expansions like ${(s:.:)} or zsh-only glob qualifiers.
# =============================================================================

# -----------------------------------------------------------------------------
# Shell detection helpers
# -----------------------------------------------------------------------------
if [ -n "${ZSH_VERSION:-}" ]; then
    _DOTFILES_SHELL="zsh"
elif [ -n "${BASH_VERSION:-}" ]; then
    _DOTFILES_SHELL="bash"
else
    _DOTFILES_SHELL="sh"
fi

# -----------------------------------------------------------------------------
# Core environment
# -----------------------------------------------------------------------------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export EDITOR='nvim'
export SVN_EDITOR='nvim'
export PAGER='less'
export LESS='-R -i -g -c -W'
export DISABLE_VERSION_CHECK=1

# fzf
export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git || find . -type f"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || head -60 {}'"

# colored man / less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

command -v lesspipe.sh >/dev/null 2>&1 && {
    export LESSOPEN='|lesspipe.sh %s'
    export LESSCLOSE='lesspipe.sh %s %s'
}

# -----------------------------------------------------------------------------
# TERM detection (Ghostty primary; WezTerm/Kitty fallbacks; tmux/ssh aware)
# Priority: tmux > ghostty > wezterm > kitty > default
# -----------------------------------------------------------------------------
_dotfiles_set_term() {
    # In tmux, always use screen-256color so nested sessions agree.
    if [ -n "${TMUX:-}" ]; then
        export TERM=screen-256color
        return 0
    fi

    # When SSH'd in, trust whatever terminfo exists; fall back to xterm-256color.
    if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_TTY:-}" ]; then
        if command -v infocmp >/dev/null 2>&1 \
            && infocmp -x "${TERM:-xterm-256color}" >/dev/null 2>&1; then
            return 0
        fi
        export TERM=xterm-256color
        return 0
    fi

    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
    local cache_file="$cache_dir/term"
    local program="${TERM_PROGRAM:-}"

    # Ghostty sets TERM=xterm-ghostty itself; keep it if terminfo is installed.
    case "$program" in
        ghostty)
            if [ -r "$cache_file.ghostty" ]; then
                IFS= read -r TERM < "$cache_file.ghostty" || TERM=xterm-256color
                export TERM
                return 0
            fi
            mkdir -p "$cache_dir"
            if command -v infocmp >/dev/null 2>&1 \
                && infocmp -x xterm-ghostty >/dev/null 2>&1; then
                printf '%s\n' xterm-ghostty >| "$cache_file.ghostty"
                export TERM=xterm-ghostty
            else
                printf '%s\n' xterm-256color >| "$cache_file.ghostty"
                export TERM=xterm-256color
            fi
            return 0
            ;;
        WezTerm)
            if [ -r "$cache_file.wezterm" ]; then
                IFS= read -r TERM < "$cache_file.wezterm" || TERM=xterm-256color
                export TERM
                return 0
            fi
            mkdir -p "$cache_dir"
            if command -v infocmp >/dev/null 2>&1 \
                && infocmp -x wezterm >/dev/null 2>&1; then
                printf '%s\n' wezterm >| "$cache_file.wezterm"
                export TERM=wezterm
            else
                printf '%s\n' xterm-256color >| "$cache_file.wezterm"
                export TERM=xterm-256color
            fi
            return 0
            ;;
    esac

    # Kitty populates its own terminfo automatically; nothing to do.
}
_dotfiles_set_term

# -----------------------------------------------------------------------------
# Homebrew China mirror (USE_CN_MIRROR=0 disables)
# -----------------------------------------------------------------------------
if [ "${USE_CN_MIRROR:-1}" = "1" ]; then
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
fi

# -----------------------------------------------------------------------------
# Common aliases (work in bash + zsh)
# -----------------------------------------------------------------------------
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
alias 。。=..
alias scp='scp -O'
alias zj='zellij attach -c'
alias zjl='zellij list-sessions'
alias zjk='zellij kill-session'

if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -l --icons'
    alias l='eza -l --icons'
    alias la='eza -la --icons'
    alias k='eza -l --icons'
else
    if [ "$(uname -s)" = "Darwin" ]; then
        alias ls='ls -G'
    else
        alias ls='ls --color=auto'
    fi
    alias ll='ls -lh'
    alias l='ls -l'
fi

# git diff viewers
if command -v delta >/dev/null 2>&1; then
    alias gd='git -c core.pager=delta -c delta.side-by-side=true -c delta.line-numbers=true -c delta.navigate=true diff'
    alias gdca='git -c core.pager=delta -c delta.side-by-side=true -c delta.line-numbers=true -c delta.navigate=true diff --cached'
    alias gdcw='git -c core.pager=delta -c delta.line-numbers=true -c delta.navigate=true diff --cached --word-diff=color'
    alias gdw='git -c core.pager=delta -c delta.line-numbers=true -c delta.navigate=true diff --word-diff=color'
elif command -v icdiff >/dev/null 2>&1; then
    alias gd='git icdiff'
    alias gdca='git icdiff --cached'
    alias gdcw='git icdiff --cached --word-diff'
    alias gdw='git icdiff --word-diff'
fi

if command -v parallel >/dev/null 2>&1; then
    alias p='parallel'
    alias pp='parallel --pipe -k'
else
    alias p='xargs -P 16'
fi

command -v tmuxinator >/dev/null 2>&1 && alias mux=tmuxinator
command -v make >/dev/null 2>&1 && alias mak='make -j 16'
command -v nvim >/dev/null 2>&1 && alias vim='nvim'
command -v watch >/dev/null 2>&1 && alias watch='watch -c'
command -v docker >/dev/null 2>&1 && alias docker='sudo -E docker'
command -v pip3 >/dev/null 2>&1 && alias pip=pip3
command -v python3 >/dev/null 2>&1 && alias python=python3
if command -v dtruss >/dev/null 2>&1 && ! command -v strace >/dev/null 2>&1; then
    alias strace='dtruss'
fi
if command -v socat >/dev/null 2>&1; then
    alias clip='socat - tcp:localhost:8377'
elif command -v nc >/dev/null 2>&1; then
    alias clip='nc localhost 8377'
fi

# -----------------------------------------------------------------------------
# NVM: lightweight default-bin bootstrap + lazy load
# Avoids paying the full nvm.sh cost at startup while still exposing `node`.
# -----------------------------------------------------------------------------
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

_nvm_is_newer_version() {
    # Returns 0 if $1 is strictly newer than $2 (by `sort -V`), else 1.
    local lhs="${1#v}" rhs="${2#v}"
    [ "$lhs" = "$rhs" ] && return 1
    [ "$(printf '%s\n%s\n' "$lhs" "$rhs" | sort -V | tail -n1)" = "$lhs" ]
}

_resolve_nvm_alias_target() {
    local target="$1"
    local alias_file depth=0

    while [ "$depth" -lt 8 ]; do
        case "$target" in
            ""|"N/A"|"system") return 1 ;;
        esac
        alias_file="$NVM_DIR/alias/$target"
        [ -f "$alias_file" ] || break
        IFS= read -r target < "$alias_file" || return 1
        depth=$((depth + 1))
    done

    [ -n "$target" ] && printf '%s\n' "$target"
}

_nvm_default_bin() {
    local target prefix dir best=""
    [ -r "$NVM_DIR/alias/default" ] || return 1
    IFS= read -r target < "$NVM_DIR/alias/default" || return 1
    target="$(_resolve_nvm_alias_target "$target")" || return 1
    prefix="$target"
    case "$prefix" in v*) ;; *) prefix="v$prefix" ;; esac

    [ -d "$NVM_DIR/versions/node" ] || return 1
    # Use `find` so we don't rely on shell-specific glob semantics.
    while IFS= read -r dir; do
        [ -n "$dir" ] || continue
        [ -x "$dir/bin/node" ] || continue
        if [ -z "$best" ] \
            || _nvm_is_newer_version "${dir##*/}" "${best##*/}"; then
            best="$dir"
        fi
    done <<EOF
$(find "$NVM_DIR/versions/node" -mindepth 1 -maxdepth 1 -type d -name "${prefix}*" 2>/dev/null)
EOF

    [ -n "$best" ] && printf '%s\n' "$best/bin"
}

_nvm_bootstrap_bin="$(_nvm_default_bin 2>/dev/null)"
if [ -n "$_nvm_bootstrap_bin" ] && [ -d "$_nvm_bootstrap_bin" ]; then
    case ":$PATH:" in
        *":$_nvm_bootstrap_bin:"*) ;;
        *)
            export PATH="$_nvm_bootstrap_bin:$PATH"
            export NVM_BIN="$_nvm_bootstrap_bin"
            ;;
    esac
fi
unset _nvm_bootstrap_bin

_lazy_load_nvm() {
    unset -f nvm 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}
nvm() { _lazy_load_nvm && nvm "$@"; }

# -----------------------------------------------------------------------------
# Atuin bin path (actual `atuin init` is wired in each shell rc because
# bash needs bash-preexec, zsh uses the cached init)
# -----------------------------------------------------------------------------
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"

# -----------------------------------------------------------------------------
# broot launcher (bash-style launcher works in both shells)
# -----------------------------------------------------------------------------
_broot_launcher="${XDG_CONFIG_HOME}/broot/launcher/bash/br"
[ -f "$_broot_launcher" ] && . "$_broot_launcher"
unset _broot_launcher

# -----------------------------------------------------------------------------
# Starship prompt (shell-aware; zsh gets cached init via _cached_eval in .zshrc)
# -----------------------------------------------------------------------------
_find_starship() {
    if command -v starship >/dev/null 2>&1; then
        command -v starship
        return 0
    fi
    local candidate
    for candidate in /opt/homebrew/bin/starship /usr/local/bin/starship \
        "$HOME/.local/bin/starship" "$HOME/bin/starship"; do
        [ -x "$candidate" ] && printf '%s\n' "$candidate" && return 0
    done
    return 1
}

# Bash inits Starship directly. Zsh's .zshrc handles it via _cached_eval for speed.
if [ "$_DOTFILES_SHELL" = "bash" ]; then
    _starship_bin="$(_find_starship)" && eval "$("$_starship_bin" init bash)"
    unset _starship_bin
fi

# -----------------------------------------------------------------------------
# Multiplexer user-var emitter (Ghostty + WezTerm both respect OSC 1337)
# -----------------------------------------------------------------------------
_emit_mux_user_var() {
    local encoded=""
    if [ -n "${TMUX:-}" ]; then
        encoded="dG11eA=="  # base64("tmux")
        printf '\033Ptmux;\033\033]1337;SetUserVar=MUX=%s\007\033\\' "$encoded"
        return 0
    fi
    if [ -n "${ZELLIJ:-}" ] || [ -n "${ZELLIJ_SESSION_NAME:-}" ]; then
        encoded="emVsbGlq"  # base64("zellij")
    fi
    printf '\033]1337;SetUserVar=MUX=%s\007' "$encoded"
}

# -----------------------------------------------------------------------------
# auto-venv (shell-specific hook wiring done in rc files)
# -----------------------------------------------------------------------------
AUTO_VENV_HELPER="${XDG_CONFIG_HOME}/shell/auto-venv.sh"
if [ ! -f "$AUTO_VENV_HELPER" ] && [ -f "$HOME/.dotfiles/.config/shell/auto-venv.sh" ]; then
    AUTO_VENV_HELPER="$HOME/.dotfiles/.config/shell/auto-venv.sh"
fi
[ -f "$AUTO_VENV_HELPER" ] && . "$AUTO_VENV_HELPER"
# AUTO_VENV_HELPER is consumed by the rc file (to set up chpwd/PROMPT_COMMAND hook)
