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
# PATH helpers (shared by bash and zsh)
# -----------------------------------------------------------------------------
path_prepend() {
    [ -n "$1" ] && [ -d "$1" ] && case ":$PATH:" in
        *":$1:"*) ;;
        *) export PATH="$1:$PATH" ;;
    esac
}
path_append() {
    [ -n "$1" ] && [ -d "$1" ] && case ":$PATH:" in
        *":$1:"*) ;;
        *) export PATH="$PATH:$1" ;;
    esac
}
path_force_prepend() {
    [ -n "$1" ] && [ -d "$1" ] || return 0

    _path_force_dir=$1
    _path_force_old=$PATH
    PATH=$_path_force_dir

    while [ -n "$_path_force_old" ]; do
        case $_path_force_old in
            *:*)
                _path_force_part=${_path_force_old%%:*}
                _path_force_old=${_path_force_old#*:}
                ;;
            *)
                _path_force_part=$_path_force_old
                _path_force_old=
                ;;
        esac

        [ "$_path_force_part" = "$_path_force_dir" ] && continue
        [ -z "$_path_force_part" ] && continue
        PATH="$PATH:$_path_force_part"
    done

    export PATH
    unset _path_force_dir _path_force_old _path_force_part
}


# -----------------------------------------------------------------------------
# Cached eval helper (shared by bash + zsh)
# -----------------------------------------------------------------------------
dotfiles_cached_eval() {
    local name=$1
    local bin=$2
    local shell_name=${3:-$_DOTFILES_SHELL}
    shift 3

    [ -n "$name" ] && [ -n "$bin" ] && [ -x "$bin" ] || return 0

    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
    [ "$shell_name" = "zsh" ] && cache_dir="${ZSH_CACHE_DIR:-$HOME/.zsh_cache}"
    local cache="$cache_dir/${name}.${shell_name}"
    local tmp

    if [ ! -f "$cache" ] || [ "$bin" -nt "$cache" ]; then
        mkdir -p "$cache_dir"
        tmp="${cache}.tmp.$$"
        if "$bin" "$@" >| "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
            mv -f "$tmp" "$cache"
        else
            rm -f "$tmp"
        fi
    fi

    [ -s "$cache" ] && . "$cache"
}

# -----------------------------------------------------------------------------
# Core environment
# -----------------------------------------------------------------------------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export EDITOR='nvim'
export SVN_EDITOR='nvim'
export PAGER='less'
export LESS='-R -i -g -c -W'
export DISABLE_VERSION_CHECK=1

# -----------------------------------------------------------------------------
# PATH — shared entries (Synology Entware, Homebrew, GNU tools, Go, etc.)
# -----------------------------------------------------------------------------
path_prepend /opt/usr/bin
path_prepend /opt/bin
path_prepend /opt/sbin

# Homebrew: on Apple Silicon, prefer /opt/homebrew over the Intel/Rosetta
# /usr/local tree. Since path_prepend puts later calls earlier in PATH, the
# order below is intentionally reversed inside the arm64 branch.
if [ "$(uname -s)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]; then
    path_prepend /usr/local/bin
    path_prepend /opt/homebrew/bin
else
    path_prepend /opt/homebrew/bin
    path_prepend /usr/local/bin
fi
path_prepend "$HOME/.local/bin"
path_prepend /usr/local/opt/findutils/libexec/gnubin
path_prepend /usr/local/opt/gnu-getopt/bin
path_prepend /usr/local/opt/ruby/bin

# Homebrew Ruby (Apple Silicon) — only prepend if the directory exists
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
    case ":$PATH:" in *":/opt/homebrew/opt/ruby/bin:"*) ;;
        *) export PATH="/opt/homebrew/opt/ruby/bin:$PATH" ;;
    esac
fi

# Go environment
if command -v go >/dev/null 2>&1 && [ -z "$GOPATH" ]; then
    export GOPATH="$HOME/gowork"
    path_append "$GOPATH/bin"
    path_append /usr/local/opt/go/libexec/bin
    export GOPROXY=https://mirrors.tencent.com/go/
fi

# Obsidian CLI
path_append "/Applications/Obsidian.app/Contents/MacOS"

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
# herdr OSC52 透传 workaround（SSH over zellij）
#
# herdr 的 should_prefer_osc52() 只检查 SSH_TTY/SSH_CONNECTION/WSL，
# 不检查 ZELLIJ。在远程 zellij session 中（SSH 环境变量不存在），
# herdr 会尝试 xclip/wl-copy 写入远端剪贴板而非透传 OSC52，
# 导致 nvim yank 的内容到不了本地 mac 剪贴板。
#
# 这里补一个环境标记：当在 zellij 中且 SSH_TTY 未设置时，伪造 SSH_TTY
# 让 herdr 优先走 OSC52 透传。去掉 pbcopy 判断是因为 SSH 到远程 Mac
# 时 pbcopy 存在但写入的是远端剪贴板，回不到本地。
# -----------------------------------------------------------------------------
if [ -n "${ZELLIJ:-}" ] && [ -z "${SSH_TTY:-}" ]; then
    export SSH_TTY="zellij"
elif [ -n "${HERDR_ENV:-}" ] && [ -z "${SSH_TTY:-}" ]; then
    export SSH_TTY="herdr"
fi

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
    alias ll='eza --icons -l'
    alias l='eza --icons -l'
    alias la='eza --icons -la'
    alias k='eza --icons -l'
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

# ouch: unified compress/decompress
command -v ouch >/dev/null 2>&1 && {
    alias x='ouch decompress'
    alias xc='ouch compress'
}

# -----------------------------------------------------------------------------
# Shared functions (cross-shell: yazi cd, venv helpers)
# -----------------------------------------------------------------------------

# yazi: cd to last-browsed directory on exit
if command -v yazi >/dev/null 2>&1; then
    y() {
        local tmp cwd
        tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi

# venv helpers: run python/pip from .venv if present
vpy() {
    local python="${PWD}/.venv/bin/python3"
    [ -x "$python" ] || python="python3"
    "$python" "$@"
}
vpip() {
    local pip="${PWD}/.venv/bin/pip3"
    [ -x "$pip" ] || pip="pip3"
    "$pip" "$@"
}

# -----------------------------------------------------------------------------
# Node.js PATH shim for npm global packages (e.g. reasonix)
# npm -g packages have shebang "#!/usr/bin/env node" and fail when node
# is not in PATH. This covers hosts where mise/nvm manage node but the
# shim path isn't active yet (non-interactive SSH, early rc ordering).
# It runs before the reasonix wrapper so `command reasonix` always works.
# -----------------------------------------------------------------------------
# Print the path of the highest-versioned subdirectory under $1 (optional $2
# glob, default '*'; optional $3 subpath that must exist under each candidate,
# e.g. "bin/node"). Version = dotted numerals with an optional leading 'v'.
# POSIX-ish: avoids GNU `sort -V`, which is unavailable on stock macOS/BSD.
# Prints nothing if no candidate matches.
_dotfiles_newest_version_dir() {
    [ -d "$1" ] || return 0
    local _root=$1 _glob=${2:-*} _need=${3:-}
    local _d _base _best="" _bestv="" _a _b _ap _bp _i
    for _d in "$_root"/$_glob; do
        [ -d "$_d" ] || continue
        [ -z "$_need" ] || [ -e "$_d/$_need" ] || continue
        _base=${_d##*/}
        case $_base in v*) _base=${_base#v} ;; esac
        case $_base in *[0-9]*) ;; *) continue ;; esac
        if [ -z "$_bestv" ]; then
            _best=$_d; _bestv=$_base; continue
        fi
        _a=$_base; _b=$_bestv
        for _i in 1 2 3 4 5; do
            _ap=${_a%%.*}; _bp=${_b%%.*}
            [ "$_ap" = "$_a" ] && _a= || _a=${_a#*.}
            [ "$_bp" = "$_b" ] && _b= || _b=${_b#*.}
            _ap=${_ap%%[^0-9]*}; _bp=${_bp%%[^0-9]*}
            _ap=${_ap:-0}; _bp=${_bp:-0}
            if [ "$_ap" -gt "$_bp" ] 2>/dev/null; then
                _best=$_d; _bestv=$_base; break
            fi
            [ "$_ap" -lt "$_bp" ] 2>/dev/null && break
        done
    done
    [ -n "$_best" ] && printf '%s\n' "$_best"
}

_dotfiles_ensure_node_path() {
    command -v node >/dev/null 2>&1 && return 0

    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
    local cache_file="$cache_dir/mise_node_path"
    local mise_node_dir="${HOME}/.local/share/mise/installs/node"
    local _mise_node_bin=""

    # Read from cache if mise installs haven't changed since we cached
    if [ -r "$cache_file" ] && [ -d "$mise_node_dir" ] && [ "$mise_node_dir" -ot "$cache_file" ]; then
        IFS= read -r _mise_node_bin < "$cache_file" || _mise_node_bin=""
    fi

    # Re-resolve when cache is missing, stale, or the cached binary went away.
    # Picks the newest mise-managed node whose bin/node exists, without GNU
    # `sort -V` (see _dotfiles_newest_version_dir above).
    if [ -z "$_mise_node_bin" ] || [ ! -x "$_mise_node_bin/node" ]; then
        _mise_node_bin=""
        local _picked
        _picked=$(_dotfiles_newest_version_dir "$mise_node_dir" "*" "bin/node")
        if [ -n "$_picked" ] && [ -x "$_picked/bin/node" ]; then
            _mise_node_bin="$_picked/bin"
            mkdir -p "$cache_dir"
            printf '%s\n' "$_mise_node_bin" >| "$cache_file" 2>/dev/null || true
        fi
    fi

    if [ -n "$_mise_node_bin" ] && [ -x "$_mise_node_bin/node" ]; then
        case ":$PATH:" in *":$_mise_node_bin:"*) ;; *) export PATH="$_mise_node_bin:$PATH" ;; esac
        return 0
    fi

    # NVM fallback: check the default alias
    local _nvm_dir=""
    if [ -r "${NVM_DIR:-$HOME/.nvm}/alias/default" ]; then
        local _nvm_target
        _nvm_target="$(head -1 "${NVM_DIR:-$HOME/.nvm}/alias/default" 2>/dev/null || true)"
        if [ -n "$_nvm_target" ]; then
            _nvm_dir="$(_dotfiles_newest_version_dir "${NVM_DIR:-$HOME/.nvm}/versions/node" "${_nvm_target}*" "bin/node")"
        fi
    fi
    if [ -n "$_nvm_dir" ] && [ -x "$_nvm_dir/bin/node" ]; then
        case ":$PATH:" in *":$_nvm_dir/bin:"*) ;; *) export PATH="$_nvm_dir/bin:$PATH" ;; esac
    fi
}
_dotfiles_ensure_node_path
unset -f _dotfiles_ensure_node_path

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
        dotfiles_cached_eval mise "$(command -v mise)" zsh activate -s zsh
    else
        dotfiles_cached_eval mise "$(command -v mise)" bash activate -s bash
    fi
else
    # Fallback: nvm lazy load (preserved for environments without mise)
    _nvm_bootstrap_bin=""
    if [ -r "$NVM_DIR/alias/default" ]; then
        _nvm_target="$(head -1 "$NVM_DIR/alias/default" 2>/dev/null || true)"
        if [ -n "$_nvm_target" ]; then
            _nvm_prefix="${_nvm_target#v}"
            _nvm_dir="$(_dotfiles_newest_version_dir "$NVM_DIR/versions/node" "v${_nvm_prefix}*" "bin/node")"
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

# Rust / Cargo
# Keep this after mise/nvm activation because mise rewrites PATH during activate.
path_append "$HOME/.cargo/bin"

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
        _jj_load() {
            dotfiles_cached_eval _jj "$(command -v jj)" zsh util completion zsh
            unset -f _jj_load 2>/dev/null || true
        }
        if typeset -f _defer >/dev/null 2>&1; then
            _defer _jj_load
        else
            _jj_load
        fi
    elif [ -n "${BASH_VERSION:-}" ]; then
        dotfiles_cached_eval jj "$(command -v jj)" bash util completion bash
    fi
fi

# -----------------------------------------------------------------------------
# Starship prompt (shell-aware; zsh gets cached init via dotfiles_cached_eval in .zshrc)
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

# Bash inits Starship directly. Zsh's .zshrc handles it via dotfiles_cached_eval
# for speed (can't use _find_starship here because .zshrc sources common.sh
# AFTER its own starship init block).
if [ "$_DOTFILES_SHELL" = "bash" ]; then
    _starship_bin="$(_find_starship)" && dotfiles_cached_eval starship "$_starship_bin" bash init bash
    unset _starship_bin
fi

# -----------------------------------------------------------------------------
# Ruby gem executable directory (cached; shared by bash + zsh)
# -----------------------------------------------------------------------------
_dotfiles_add_gem_bin() {
    command -v gem >/dev/null 2>&1 || return 0

    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
    local cache_file="$cache_dir/gem_bin_path"
    local gem_bin=""
    local gem_cmd
    gem_cmd="$(command -v gem 2>/dev/null)" || return 0

    if [ -r "$cache_file" ] && [ "$gem_cmd" -ot "$cache_file" ]; then
        IFS= read -r gem_bin < "$cache_file" || gem_bin=""
    fi

    if [ -z "$gem_bin" ] || [ ! -d "$gem_bin" ]; then
        gem_bin="$(gem environment gemdir 2>/dev/null)/bin"
        if [ -d "$gem_bin" ]; then
            mkdir -p "$cache_dir"
            printf '%s\n' "$gem_bin" >| "$cache_file" 2>/dev/null || true
        fi
    fi

    if [ -d "$gem_bin" ]; then
        case ":$PATH:" in *":$gem_bin:"*) ;; *) export PATH="$PATH:$gem_bin" ;; esac
    fi
}
_dotfiles_add_gem_bin
unset -f _dotfiles_add_gem_bin

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
        if typeset -f _defer >/dev/null 2>&1; then
            _defer dotfiles_cached_eval direnv "$(command -v direnv)" zsh hook zsh
        else
            dotfiles_cached_eval direnv "$(command -v direnv)" zsh hook zsh
        fi
    else
        dotfiles_cached_eval direnv "$(command -v direnv)" bash hook bash
    fi
fi

# -----------------------------------------------------------------------------
# API key environment (shared by bash and zsh)
# -----------------------------------------------------------------------------
[ -f "$HOME/.api_key_env" ] && . "$HOME/.api_key_env"
