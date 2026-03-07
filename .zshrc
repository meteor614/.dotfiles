# 阻止 oh-my-zsh 重复调用 compinit
skip_global_compinit=1
export ZSH_DISABLE_COMPFIX="true"

# 强制设置缓存路径
export ZSH_CACHE_DIR="${HOME}/.zsh_cache"
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"
mkdir -p "$ZSH_CACHE_DIR"

# 2. 禁用 compaudit（节省 53ms）
zstyle ':omz:initialize' skip-compaudit 'yes'

# 3. 禁用 oh-my-zsh 自动更新（节省 27ms）
zstyle ':omz:update' mode disabled

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(git)
# plugins=(git zsh-autosuggestions zsh-syntax-highlighting z extract web-search)
plugins=(git z extract zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
nvm() { _lazy_load_nvm; nvm "$@" }
node() { _lazy_load_nvm; node "$@" }
npm() { _lazy_load_nvm; npm "$@" }
npx() { _lazy_load_nvm; npx "$@" }

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
    eval "$(atuin init zsh)"
fi

source /Users/meteorchen/.config/broot/launcher/bash/br
