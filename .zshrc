# ~/.zshrc — zsh-specific bits; shared logic in
# $XDG_CONFIG_HOME/shell/common.sh (sourced below).

# ── Fix fpath after brew zsh upgrades ────────────────────────────────────────
# Homebrew's zsh binary bakes in a Cellar-versioned functions path that breaks
# whenever zsh is upgraded (e.g. 5.9 -> 5.9.1). Prepend the stable symlinked
# locations so compinit/add-zsh-hook/is-at-least/compdef are always findable.
# Guard on /opt/homebrew to skip the loop entirely on Linux/remote hosts.
if [[ -d /opt/homebrew ]]; then
    for _zfn in /opt/homebrew/share/zsh/functions /opt/homebrew/share/zsh/site-functions; do
        [[ -d $_zfn ]] && fpath=($_zfn $fpath)
    done
fi
unset _zfn

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
    compinit -i -d "$ZSH_COMPDUMP"
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
# share_history is intentionally omitted — disabled in .zshrc.local because
# inter-session history sharing conflicts with atuin's own history sync.

# ── Plugins (direct source, no oh-my-zsh framework) ─────────────────────────
# Cloned by setup.sh into an XDG data dir. zsh-syntax-highlighting wraps ZLE
# widgets, so any widgets bound later (e.g. in ~/.zshrc.local) won't be
# highlighted.
_zsh_plugins_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
[[ -f "$_zsh_plugins_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$_zsh_plugins_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$_zsh_plugins_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$_zsh_plugins_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unset _zsh_plugins_dir

# ── Cached eval helper (zsh-only, used for starship/zoxide/atuin init) ───────
_cached_eval() {
    local name="$1" bin="$2"; shift 2
    local cache="$ZSH_CACHE_DIR/${name}.zsh"
    if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
        local tmp="${cache}.tmp.$$"
        if "$bin" "$@" >| "$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
            mv -f "$tmp" "$cache"
        else
            rm -f "$tmp"
        fi
    fi
    [[ -s "$cache" ]] && source "$cache"
}

# ── Deferred init helper (zsh-only) ─────────────────────────────────────────
# Queue non-critical init commands and run them once from the parent shell at
# the first prompt. These commands often source files or install hooks, so they
# must not run in a background subshell.
autoload -Uz add-zsh-hook
typeset -ga _dotfiles_deferred_cmds
_dotfiles_deferred_cmds=()
_defer() {
    _dotfiles_deferred_cmds+=("${(j: :)${(@q)@}}")
}
_dotfiles_run_deferred() {
    add-zsh-hook -d precmd _dotfiles_run_deferred 2>/dev/null || true
    local _cmd
    for _cmd in "${_dotfiles_deferred_cmds[@]}"; do
        eval "$_cmd"
    done
    unset _cmd _dotfiles_deferred_cmds
    unset -f _dotfiles_run_deferred _defer 2>/dev/null || true
}
add-zsh-hook precmd _dotfiles_run_deferred

(( $+commands[zoxide] )) && _cached_eval zoxide "${commands[zoxide]}" init zsh

# ── Starship (cached init; single command probe) ─────────────────────────────
# NOTE: _find_starship is defined in common.sh but not available here yet
# (common.sh is sourced after this block). Duplicated probe is intentional:
# zsh uses _cached_eval for speed, bash uses common.sh's _find_starship.
if (( $+commands[starship] )); then
    _cached_eval starship "${commands[starship]}" init zsh
else
    _starship_bin=""
    for _c in /opt/homebrew/bin/starship /usr/local/bin/starship \
              "$HOME/.local/bin/starship" "$HOME/bin/starship"; do
        [[ -x "$_c" ]] && _starship_bin="$_c" && break
    done
    [[ -n "$_starship_bin" ]] && _cached_eval starship "$_starship_bin" init zsh
    unset _c _starship_bin
fi

# ── Shared config (aliases, TERM, NVM lazy loader, Homebrew mirror, …) ───────
# NOTE: This path resolution is duplicated in .bashrc because bash has no
# equivalent of .zshenv for early shared init. Keep both in sync.
_common_sh="${XDG_CONFIG_HOME:-$HOME/.config}/shell/common.sh"
[[ ! -f "$_common_sh" && -f "$HOME/.dotfiles/.config/shell/common.sh" ]] \
    && _common_sh="$HOME/.dotfiles/.config/shell/common.sh"
[[ -f "$_common_sh" ]] && source "$_common_sh"
unset _common_sh

# ── User configuration (local overrides) ─────────────────────────────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# ── Conda lazy loader (zsh-specific hook) ────────────────────────────────────
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

# ── Atuin (zsh has native preexec; no bash-preexec needed) ───────────────────
(( $+commands[atuin] )) && _cached_eval atuin atuin init zsh

# ── auto-venv: wire chpwd hook (common.sh sourced the helper file) ───────────
if [[ -n "${AUTO_VENV_HELPER:-}" && -f "$AUTO_VENV_HELPER" ]]; then
    autoload -Uz add-zsh-hook
    if (( ! ${chpwd_functions[(I)_auto_venv_refresh]:-0} )); then
        add-zsh-hook chpwd _auto_venv_refresh
    fi
    _auto_venv_refresh
fi
unset AUTO_VENV_HELPER

# ── Ensure $HOME/bin stays at the front of PATH ──────────────────────────────
# Placed last so any later prepends (Ruby, gem bindir, etc.) can't shadow it.
if [[ -d "$HOME/bin" ]]; then
    path_force_prepend "$HOME/bin"
fi

# ── Multiplexer user-var emitter (tells WezTerm/Ghostty inner mux) ───────────
if [[ -o interactive ]] \
    && (( ${precmd_functions[(Ie)_emit_mux_user_var]:-0} == 0 )); then
    precmd_functions+=(_emit_mux_user_var)
fi

# kimi-code
if [[ -d "$HOME/.kimi-code/bin" ]]; then
    path=("$HOME/.kimi-code/bin" $path)
fi

# mimocode
if [[ -d "$HOME/.mimocode/bin" ]]; then
    path=("$HOME/.mimocode/bin" $path)
fi
