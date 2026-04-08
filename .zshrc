# ── Completion system (replaces oh-my-zsh compinit) ──────────────────────────
export ZSH_CACHE_DIR="${HOME}/.zsh_cache"
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"
mkdir -p "$ZSH_CACHE_DIR"
export STARSHIP_CACHE="${ZSH_CACHE_DIR}/starship"
mkdir -p "$STARSHIP_CACHE"

autoload -Uz compinit
# Rebuild dump only once per day (skip security check for speed)
if [[ -f "$ZSH_COMPDUMP" && "$ZSH_COMPDUMP"(N.mh+24) == "" ]]; then
    compinit -C -d "$ZSH_COMPDUMP"
else
    compinit -d "$ZSH_COMPDUMP"
fi

# ── Completion styles (from oh-my-zsh lib/completion.zsh) ────────────────────
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"

# ── Key bindings (emacs mode + common terminal keys) ─────────────────────────
bindkey -e
bindkey '^[[A' up-line-or-search          # Up arrow: history search
bindkey '^[[B' down-line-or-search        # Down arrow: history search
bindkey '^[[H' beginning-of-line          # Home
bindkey '^[[F' end-of-line                # End
bindkey '^[[3~' delete-char               # Delete

# ── History settings ─────────────────────────────────────────────────────────
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history

# ── PATH ─────────────────────────────────────────────────────────────────────
# Synology Entware & common extra paths
for _p in /opt/usr/bin /opt/bin /opt/sbin $HOME/bin $HOME/.local/bin /usr/local/bin; do
    [[ -d "$_p" && ":$PATH:" != *":$_p:"* ]] && PATH="$_p:$PATH"
done
unset _p
export PATH

# ── oh-my-zsh directory (kept for extract plugin & custom plugins) ───────────
export ZSH="$HOME/.oh-my-zsh"

# ── Plugins (direct source, no oh-my-zsh framework) ─────────────────────────
# extract
[[ -f "$ZSH/plugins/extract/extract.plugin.zsh" ]] && source "$ZSH/plugins/extract/extract.plugin.zsh"

# zsh-autosuggestions
[[ -f "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-syntax-highlighting (must be sourced last among plugins)
[[ -f "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── Cached eval helper ───────────────────────────────────────────────────────
_cached_eval() {
    local name="$1" bin="$2"; shift 2
    local cache="$ZSH_CACHE_DIR/${name}.zsh"
    if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
        "$bin" "$@" >| "$cache" 2>/dev/null
    fi
    source "$cache"
}

if (( $+commands[zoxide] )); then
    _cached_eval zoxide zoxide init zsh
fi

_init_starship() {
    (( ${+_starship_initialized} )) && return 0

    local starship_bin=""
    if (( $+commands[starship] )); then
        starship_bin="$(command -v starship)"
    elif [[ -x /usr/local/bin/starship ]]; then
        starship_bin="/usr/local/bin/starship"
    elif [[ -x /opt/homebrew/bin/starship ]]; then
        starship_bin="/opt/homebrew/bin/starship"
    elif [[ -x "$HOME/.local/bin/starship" ]]; then
        starship_bin="$HOME/.local/bin/starship"
    elif [[ -x "$HOME/bin/starship" ]]; then
        starship_bin="$HOME/bin/starship"
    fi

    [[ -n "$starship_bin" ]] || return 0
    _cached_eval starship "$starship_bin" init zsh
    typeset -g _starship_initialized=1
}

_init_starship

# ── User configuration ────────────────────────────────────────────────────────

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# 轻量注入默认 Node 版本的 bin，让全局 npm 命令在新 shell 中直接可用。
_nvm_is_newer_version() {
    local lhs="${1#v}" rhs="${2#v}"
    local -a lhs_parts rhs_parts
    lhs_parts=(${(s:.:)lhs})
    rhs_parts=(${(s:.:)rhs})

    local i max_parts=$(( ${#lhs_parts} > ${#rhs_parts} ? ${#lhs_parts} : ${#rhs_parts} ))
    for (( i = 1; i <= max_parts; i++ )); do
        local l="${lhs_parts[i]:-0}"
        local r="${rhs_parts[i]:-0}"
        (( l > r )) && return 0
        (( l < r )) && return 1
    done
    return 1
}

_resolve_nvm_alias_target() {
    local target="$1"
    local alias_file depth=0

    while (( depth < 8 )); do
        case "$target" in
            ""|"N/A"|"system")
                return 1
                ;;
        esac

        alias_file="$NVM_DIR/alias/$target"
        [[ -f "$alias_file" ]] || break
        IFS= read -r target < "$alias_file" || return 1
        (( depth++ ))
    done

    [[ -n "$target" ]] && print -r -- "$target"
}

_nvm_default_bin() {
    local target prefix dir best=""

    [[ -r "$NVM_DIR/alias/default" ]] || return 1
    IFS= read -r target < "$NVM_DIR/alias/default" || return 1
    target="$(_resolve_nvm_alias_target "$target")" || return 1

    prefix="$target"
    [[ "$prefix" == v* ]] || prefix="v$prefix"

    for dir in "$NVM_DIR"/versions/node/${prefix}*(N/); do
        dir="${dir%/}"
        [[ -x "$dir/bin/node" ]] || continue
        if [[ -z "$best" ]] || _nvm_is_newer_version "${dir:t}" "${best:t}"; then
            best="$dir"
        fi
    done

    [[ -n "$best" ]] && print -r -- "$best/bin"
}

_nvm_bootstrap_bin="$(_nvm_default_bin 2>/dev/null)"
if [[ -n "$_nvm_bootstrap_bin" && ":$PATH:" != *":$_nvm_bootstrap_bin:"* ]]; then
    export PATH="$_nvm_bootstrap_bin:$PATH"
    export NVM_BIN="$_nvm_bootstrap_bin"
fi
unset _nvm_bootstrap_bin

# 延迟加载 NVM (支持 nvm/node/npm/npx 命令)
_lazy_load_nvm() {
    unset -f nvm node npm npx 2>/dev/null
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
nvm()  { unset -f nvm node npm npx 2>/dev/null; _lazy_load_nvm; nvm  "$@" }
node() { unset -f nvm node npm npx 2>/dev/null; _lazy_load_nvm; node "$@" }
npm()  { unset -f nvm node npm npx 2>/dev/null; _lazy_load_nvm; npm  "$@" }
npx()  { unset -f nvm node npm npx 2>/dev/null; _lazy_load_nvm; npx  "$@" }

# 延迟加载 conda，兼容本地 macOS 和远程 Linux 的常见安装路径。
_find_conda_exe() {
    local candidate
    for candidate in \
        "${CONDA_EXE:-}" \
        "/opt/homebrew/Caskroom/miniforge/base/bin/conda" \
        "$HOME/miniforge3/bin/conda" \
        "$HOME/miniconda3/bin/conda" \
        "$HOME/anaconda3/bin/conda"
    do
        [[ -n "$candidate" && -x "$candidate" ]] && print -r -- "$candidate" && return 0
    done

    (( $+commands[conda] )) && command -v conda
}

_lazy_load_conda() {
    unset -f conda mamba 2>/dev/null

    local conda_exe conda_root conda_sh
    conda_exe="$(_find_conda_exe)" || return 1
    conda_root="${conda_exe:h:h}"
    conda_sh="$conda_root/etc/profile.d/conda.sh"

    if [[ -f "$conda_sh" ]]; then
        . "$conda_sh"
    else
        eval "$("$conda_exe" shell.zsh hook 2>/dev/null)"
    fi
}
conda() { _lazy_load_conda && conda "$@" }
mamba() { _lazy_load_conda && mamba "$@" }

[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"

if (( $+commands[atuin] )); then
    _cached_eval atuin atuin init zsh
fi

AUTO_VENV_HELPER="${XDG_CONFIG_HOME:-$HOME/.config}/shell/auto-venv.sh"
if [[ ! -f "$AUTO_VENV_HELPER" && -f "$HOME/.dotfiles/.config/shell/auto-venv.sh" ]]; then
    AUTO_VENV_HELPER="$HOME/.dotfiles/.config/shell/auto-venv.sh"
fi
if [[ -f "$AUTO_VENV_HELPER" ]]; then
    . "$AUTO_VENV_HELPER"
    autoload -Uz add-zsh-hook
    if (( ! ${chpwd_functions[(I)_auto_venv_refresh]:-0} )); then
        add-zsh-hook chpwd _auto_venv_refresh
    fi
    _auto_venv_refresh
fi
unset AUTO_VENV_HELPER

BROOT_LAUNCHER="${XDG_CONFIG_HOME:-$HOME/.config}/broot/launcher/bash/br"
[ -f "$BROOT_LAUNCHER" ] && source "$BROOT_LAUNCHER"
unset BROOT_LAUNCHER
