# ~/.zshrc — zsh-specific bits; shared logic in
# $XDG_CONFIG_HOME/shell/common.sh (sourced below).

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
setopt share_history

# ── PATH (prepend common locations; de-duplicated) ───────────────────────────
for _p in /opt/usr/bin /opt/bin /opt/sbin $HOME/bin $HOME/.local/bin /usr/local/bin; do
    [[ -d "$_p" && ":$PATH:" != *":$_p:"* ]] && PATH="$_p:$PATH"
done
unset _p
export PATH

# ── oh-my-zsh directory (kept for extract plugin & custom plugins) ───────────
export ZSH="$HOME/.oh-my-zsh"

# ── Plugins (direct source, no oh-my-zsh framework) ─────────────────────────
[[ -f "$ZSH/plugins/extract/extract.plugin.zsh" ]] && source "$ZSH/plugins/extract/extract.plugin.zsh"
[[ -f "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [[ -f "$ZSH/custom/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
    source "$ZSH/custom/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
elif [[ -f "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

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

(( $+commands[zoxide] )) && _cached_eval zoxide zoxide init zsh

# ── Starship (cached init; single command probe) ─────────────────────────────
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

# ── Homebrew Ruby gem bin ────────────────────────────────────────────────────
if [[ -d "/opt/homebrew/opt/ruby/bin" ]]; then
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    if (( $+commands[gem] )); then
        local _gemdir
        _gemdir="$(gem environment gemdir 2>/dev/null)/bin"
        [[ -d "$_gemdir" ]] && export PATH="$_gemdir:$PATH"
        unset _gemdir
    fi
fi

# ── Multiplexer user-var emitter (tells WezTerm/Ghostty inner mux) ───────────
if [[ -o interactive ]] \
    && (( ${precmd_functions[(Ie)_emit_mux_user_var]:-0} == 0 )); then
    precmd_functions+=(_emit_mux_user_var)
fi
