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
    # Primary: TUNA — best overall coverage, stable CDN in China
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
fi

# -----------------------------------------------------------------------------
# brew wrapper with mirror fallback — swap provider on failure
# -----------------------------------------------------------------------------
if [ "${USE_CN_MIRROR:-1}" = "1" ] && command -v brew >/dev/null 2>&1; then
    _DOTFILES_BREW="$(command -v brew)"
    brew() {
        local _dotfiles_brew_exit=0
        "$_DOTFILES_BREW" "$@" || {
            _dotfiles_brew_exit=$?
            echo "dotfiles: primary mirror failed, retrying with Tencent Cloud..." >&2
            HOMEBREW_API_DOMAIN="https://mirrors.cloud.tencent.com/homebrew-bottles/api" \
            HOMEBREW_BOTTLE_DOMAIN="https://mirrors.cloud.tencent.com/homebrew-bottles" \
            HOMEBREW_BREW_GIT_REMOTE="https://mirrors.cloud.tencent.com/homebrew/brew.git" \
            HOMEBREW_CORE_GIT_REMOTE="https://mirrors.cloud.tencent.com/homebrew/homebrew-core.git" \
            "$_DOTFILES_BREW" "$@"
            _dotfiles_brew_exit=$?
        }
        return $_dotfiles_brew_exit
    }
fi

# -----------------------------------------------------------------------------
# Common aliases (work in bash + zsh)
# -----------------------------------------------------------------------------
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
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

# ── Git shorthand (shared by bash and zsh) ───────────────────────────────────
alias gc='git commit'
alias ga='git add'
alias gst='git status'
alias gl='git pull'
alias gp='git push'
alias grh='git reset'
alias grhh='git reset --hard'
alias gsu='git submodule update'

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
# docker: only escalate via sudo on Linux when the user lacks docker access.
# On macOS (Docker Desktop), rootless docker, or when already in the docker
# group / running as root, plain `docker` works and sudo would be wrong.
if command -v docker >/dev/null 2>&1; then
    if [ "$(uname -s)" = "Linux" ] && [ "$(id -u)" -ne 0 ] \
        && ! id -nG 2>/dev/null | tr ' ' '\n' | grep -qx docker; then
        alias docker='sudo -E docker'
    fi
fi
if command -v pip3 >/dev/null 2>&1; then
    pip() {
        if [ -n "${VIRTUAL_ENV:-}" ] && [ -x "${VIRTUAL_ENV}/bin/pip" ]; then
            "${VIRTUAL_ENV}/bin/pip" "$@"
        else
            command pip3 "$@"
        fi
    }
fi
if command -v python3 >/dev/null 2>&1; then
    python() {
        if [ -n "${VIRTUAL_ENV:-}" ] && [ -x "${VIRTUAL_ENV}/bin/python" ]; then
            "${VIRTUAL_ENV}/bin/python" "$@"
        else
            command python3 "$@"
        fi
    }
fi
if command -v dtruss >/dev/null 2>&1 && ! command -v strace >/dev/null 2>&1; then
    alias strace='dtruss'
fi
if command -v claude-internal >/dev/null 2>&1; then
    if [ "$(id -u)" -ne 0 ]; then
        alias claude-internal='claude-internal --allow-dangerously-skip-permissions'
        alias cci='claude-internal --allow-dangerously-skip-permissions'
    else
        alias cci='claude-internal'
    fi
fi

# Reasonix 1.2.0+ fires UserPromptSubmit and Stop hooks (via settings.json),
# so the turn lifecycle is precise. The wrapper still handles two edge cases:
#   1. pre-announces idle on startup → herdr recognizes pane immediately
#      (before the first UserPromptSubmit fires)
#   2. releases the agent on exit → herdr clears the stale label
if command -v reasonix >/dev/null 2>&1; then
    reasonix() {
        local hook="$HOME/.reasonix/hooks/herdr-agent-state.sh"
        if [ "${HERDR_ENV:-}" = "1" ] && [ -x "$hook" ]; then
            bash "$hook" idle </dev/null >/dev/null 2>&1 || true
        fi
        command reasonix "$@"
        local rc=$?
        if [ "${HERDR_ENV:-}" = "1" ] && [ -x "$hook" ]; then
            bash "$hook" release </dev/null >/dev/null 2>&1 || true
        fi
        return $rc
    }
fi

# -----------------------------------------------------------------------------
# Mise: unified runtime version manager (node/python/go/ruby)
# Falls back to nvm when mise is not installed (remote hosts).
# -----------------------------------------------------------------------------
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if command -v mise >/dev/null 2>&1; then
    # mise activate: installs chpwd/precmd hooks so .tool-versions in
    # subdirectories automatically switch runtime versions on cd.
    # Output is cached so mise is only forked once per binary update.
    if [ -n "${ZSH_VERSION:-}" ]; then
        # _cached_eval is defined in .zshrc before common.sh is sourced
        _cached_eval mise "${commands[mise]}" activate -s zsh
    else
        # Bash inline cache (no _cached_eval helper available)
        _mise_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/mise.bash"
        if [ ! -f "$_mise_cache" ] || [ "$(command -v mise)" -nt "$_mise_cache" ]; then
            mkdir -p "$(dirname "$_mise_cache")"
            mise activate -s bash >| "$_mise_cache" 2>/dev/null || rm -f "$_mise_cache"
        fi
        [ -s "$_mise_cache" ] && source "$_mise_cache"
        unset _mise_cache
    fi
else
    # Fallback: nvm lazy load (preserved for environments without mise)
    _nvm_bootstrap_bin=""
    if [ -r "$NVM_DIR/alias/default" ]; then
        _nvm_target="$(head -1 "$NVM_DIR/alias/default" 2>/dev/null || true)"
        if [ -n "$_nvm_target" ]; then
            _nvm_prefix="${_nvm_target#v}"
            _nvm_dir="$(find "$NVM_DIR/versions/node" -maxdepth 1 -type d -name "v${_nvm_prefix}*" 2>/dev/null | sort -V | tail -1 || true)"
            if [ -n "$_nvm_dir" ] && [ -x "$_nvm_dir/bin/node" ]; then
                _nvm_bootstrap_bin="$_nvm_dir/bin"
            fi
        fi
    fi
    if [ -n "$_nvm_bootstrap_bin" ] && [ -d "$_nvm_bootstrap_bin" ]; then
        case ":$PATH:" in *":$_nvm_bootstrap_bin:"*) ;; *)
            export PATH="$_nvm_bootstrap_bin:$PATH"
            export NVM_BIN="$_nvm_bootstrap_bin"
        ;; esac
    fi
    unset _nvm_target _nvm_prefix _nvm_dir _nvm_bootstrap_bin

    _lazy_load_nvm() {
        unset -f nvm 2>/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    }
    nvm() { _lazy_load_nvm && nvm "$@"; }
fi
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
# jj (Jujutsu) — git-compatible VCS; completion wired per shell
# -----------------------------------------------------------------------------
if command -v jj >/dev/null 2>&1; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        # Lazy-load zsh completion (generate once, cache it)
        _jj_cache="${ZSH_CACHE_DIR:-$HOME/.zsh_cache}/_jj"
        if [ ! -f "$_jj_cache" ] || [ "$(command -v jj)" -nt "$_jj_cache" ]; then
            mkdir -p "$(dirname "$_jj_cache")"
            jj util completion zsh >| "$_jj_cache" 2>/dev/null || rm -f "$_jj_cache"
        fi
        [ -s "$_jj_cache" ] && source "$_jj_cache"
        unset _jj_cache
    elif [ -n "${BASH_VERSION:-}" ]; then
        source <(jj util completion bash 2>/dev/null) 2>/dev/null || true
    fi
fi

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

# -----------------------------------------------------------------------------
# direnv: per-directory environment (hook cached to avoid fork on every shell)
# -----------------------------------------------------------------------------
if command -v direnv >/dev/null 2>&1; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        _cached_eval direnv "${commands[direnv]}" hook zsh
    else
        _direnv_cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/direnv.bash"
        if [ ! -f "$_direnv_cache" ] || [ "$(command -v direnv)" -nt "$_direnv_cache" ]; then
            mkdir -p "$(dirname "$_direnv_cache")"
            direnv hook bash >| "$_direnv_cache" 2>/dev/null || rm -f "$_direnv_cache"
        fi
        [ -s "$_direnv_cache" ] && source "$_direnv_cache"
        unset _direnv_cache
    fi
fi
