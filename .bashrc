
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

alias 。。=..

if type eza>/dev/null 2>&1; then
    alias ll='eza -l'
    alias l='eza -l'
    alias la='eza -la'
    alias k='eza -l'
    alias ls='eza'
else
    alias ls='ls -G --color'
    alias ll='ls -lh'
    alias l='ls -l'
fi

export PS1='[\u@\h \w]$ '

# git diff viewers
if type delta>/dev/null 2>&1; then
    alias gd='git -c core.pager=delta -c delta.side-by-side=true -c delta.line-numbers=true -c delta.navigate=true diff'
    alias gdca='git -c core.pager=delta -c delta.side-by-side=true -c delta.line-numbers=true -c delta.navigate=true diff --cached'
    alias gdcw='git -c core.pager=delta -c delta.line-numbers=true -c delta.navigate=true diff --cached --word-diff=color'
    alias gdw='git -c core.pager=delta -c delta.line-numbers=true -c delta.navigate=true diff --word-diff=color'
elif type icdiff>/dev/null 2>&1; then
    alias gd='git icdiff'
    alias gdca='git icdiff --cached'
    alias gdcw='git icdiff --cached --word-diff'
    alias gdw='git icdiff --word-diff'
fi
# parallel
if type parallel>/dev/null 2>&1; then
    alias p='parallel'
    alias pp='parallel --pipe -k'
else
    alias p='xargs -P 16'
fi
alias scp="scp -O"
alias zj="zellij attach -c"
alias zjl="zellij list-sessions"
alias zjk="zellij kill-session"

# fzf - 与 zsh 保持一致
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git 2>/dev/null || rg --files --hidden --follow --glob '!.git/*' 2>/dev/null || find . -type f"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || head -60 {}'"

export SVN_EDITOR='vim'
export EDITOR='vim'
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
# 保留本地 WezTerm 特性；只在 terminfo 可用时启用 wezterm TERM。
if [ -n "$TMUX" ]; then
    export TERM=screen-256color
elif [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ]; then
    if command -v infocmp >/dev/null 2>&1 && infocmp -x "${TERM:-xterm-256color}" >/dev/null 2>&1; then
        :
    else
        export TERM=xterm-256color
    fi
elif [ "${TERM_PROGRAM:-}" = "WezTerm" ]; then
    if command -v infocmp >/dev/null 2>&1 && infocmp -x wezterm >/dev/null 2>&1; then
        export TERM=wezterm
    else
        export TERM=xterm-256color
    fi
fi

# pager
export PAGER="less"
export LESS="-R -i -g -c -W"
type lesspipe.sh>/dev/null 2>&1 && export LESSOPEN='|lesspipe.sh %s' && export LESSCLOSE='lesspipe.sh %s %s'
# color man
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Homebrew Tsinghua Mirror（USE_CN_MIRROR=0 可关闭）
if [ "${USE_CN_MIRROR:-1}" = "1" ]; then
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
fi

[ -f ~/perl5/perlbrew/etc/bashrc ] && source ~/perl5/perlbrew/etc/bashrc

# if [ -f /usr/libexec/java_home ]; then
#     export JAVA_HOME=`/usr/libexec/java_home`
#     if [ "$JAVA_HOME" =~ '.*JavaApplet.*' ]; then
#         export JAVA_HOME=`/usr/libexec/java_home -V 2>&1|grep 'SE'|head -1|awk -F'\" ' '{print $3}'`
#     fi
#     export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
#     export PATH="$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin"
# fi

if [ -d /opt/homebrew/bin ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi
if [ -d /usr/local/bin ]; then
    export PATH="/usr/local/bin:$PATH"
fi
if [ -d /opt/bin ]; then
    export PATH="/opt/bin:$PATH"
fi
if [ -d /usr/local/opt/findutils/libexec/gnubin ]; then
    export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
fi
if [ -d /usr/local/opt/gnu-getopt/bin ]; then
    export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"
fi
if [ -d /usr/local/opt/ruby/bin ]; then
    export PATH="/usr/local/opt/ruby/bin:$PATH"
fi

test -d $HOME/bin && export PATH="$PATH:$HOME/bin"
test -d $HOME/.local/bin && export PATH="$PATH:$HOME/.local/bin"

if type go >/dev/null 2>&1 && [ -z "$GOPATH" ]; then
    export GOPATH=$HOME/gowork
    export PATH="$PATH:$GOPATH/bin:/usr/local/opt/go/libexec/bin"
    export GOPROXY=https://mirrors.tencent.com/go/
fi

export NVM_DIR="$HOME/.nvm"

_nvm_is_newer_version() {
    local lhs="${1#v}" rhs="${2#v}"
    local lhs_i rhs_i lhs_part rhs_part
    local lhs_parts rhs_parts

    IFS='.' read -r -a lhs_parts <<< "$lhs"
    IFS='.' read -r -a rhs_parts <<< "$rhs"

    local max_parts=${#lhs_parts[@]}
    if [ ${#rhs_parts[@]} -gt "$max_parts" ]; then
        max_parts=${#rhs_parts[@]}
    fi

    for (( lhs_i = 0; lhs_i < max_parts; lhs_i++ )); do
        lhs_part="${lhs_parts[lhs_i]:-0}"
        rhs_part="${rhs_parts[lhs_i]:-0}"
        if (( lhs_part > rhs_part )); then
            return 0
        fi
        if (( lhs_part < rhs_part )); then
            return 1
        fi
    done

    return 1
}

_resolve_nvm_alias_target() {
    local target="$1"
    local alias_file depth=0

    while [ "$depth" -lt 8 ]; do
        case "$target" in
            ""|"N/A"|"system")
                return 1
                ;;
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
    local had_nullglob=0

    [ -r "$NVM_DIR/alias/default" ] || return 1
    IFS= read -r target < "$NVM_DIR/alias/default" || return 1
    target="$(_resolve_nvm_alias_target "$target")" || return 1

    prefix="$target"
    case "$prefix" in
        v*) ;;
        *) prefix="v$prefix" ;;
    esac

    shopt -q nullglob && had_nullglob=1
    shopt -s nullglob
    for dir in "$NVM_DIR"/versions/node/${prefix}*/; do
        dir="${dir%/}"
        [ -x "$dir/bin/node" ] || continue
        if [ -z "$best" ] || _nvm_is_newer_version "$(basename "$dir")" "$(basename "$best")"; then
            best="$dir"
        fi
    done
    if [ "$had_nullglob" -eq 0 ]; then
        shopt -u nullglob
    fi

    [ -n "$best" ] && printf '%s\n' "$best/bin"
}

_nvm_bootstrap_bin="$(_nvm_default_bin 2>/dev/null)"
if [ -n "$_nvm_bootstrap_bin" ] && [[ ":$PATH:" != *":$_nvm_bootstrap_bin:"* ]]; then
    export PATH="$_nvm_bootstrap_bin:$PATH"
    export NVM_BIN="$_nvm_bootstrap_bin"
fi
unset _nvm_bootstrap_bin

_lazy_load_nvm() {
    unset -f nvm node npm npx 2>/dev/null
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}
nvm() { _lazy_load_nvm; nvm "$@"; }
node() { _lazy_load_nvm; node "$@"; }
npm() { _lazy_load_nvm; npm "$@"; }
npx() { _lazy_load_nvm; npx "$@"; }

type thefuck >/dev/null 2>&1 && eval $(thefuck --alias)
[ -e "$HOME/.iterm2_shell_integration.zsh" ] && source "$HOME/.iterm2_shell_integration.zsh"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
type kubectl >/dev/null 2>&1 && source <(kubectl completion bash)

type tmuxinator >/dev/null 2>&1 && alias mux=tmuxinator
type make >/dev/null 2>&1 && alias mak='make -j 16'
type nvim >/dev/null 2>&1 && alias vim='nvim'
type pip3 >/dev/null 2>&1 && alias pip=pip3
type watch >/dev/null 2>&1 && alias watch='watch -c'
type docker >/dev/null 2>&1 && alias docker='sudo -E docker'
type dtruss >/dev/null 2>&1 && ! type strace >/dev/null 2>&1 && alias strace='dtruss'

if type socat>/dev/null 2>&1; then
    alias clip="socat - tcp:localhost:8377"
elif type nc >/dev/null 2>&1; then
    alias clip="nc localhost 8377"
fi

[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"

if type atuin >/dev/null 2>&1; then
    [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
    eval "$(atuin init bash)"
fi

# 告诉 WezTerm 当前 multiplexer；ssh 到远端再进 tmux 时也能识别。
_wezterm_emit_mux_user_var() {
    local encoded=""

    if [ -n "$TMUX" ]; then
        encoded="dG11eA=="
        printf '\033Ptmux;\033\033]1337;SetUserVar=MUX=%s\007\033\\' "$encoded"
        return 0
    fi

    if [ -n "$ZELLIJ" ] || [ -n "$ZELLIJ_SESSION_NAME" ]; then
        encoded="emVsbGlq"
    fi

    printf '\033]1337;SetUserVar=MUX=%s\007' "$encoded"
}

case ";$PROMPT_COMMAND;" in
    *";_wezterm_emit_mux_user_var;"*) ;;
    *)
        if [ -n "$PROMPT_COMMAND" ]; then
            PROMPT_COMMAND="_wezterm_emit_mux_user_var;$PROMPT_COMMAND"
        else
            PROMPT_COMMAND="_wezterm_emit_mux_user_var"
        fi
        ;;
esac

BROOT_LAUNCHER="${XDG_CONFIG_HOME:-$HOME/.config}/broot/launcher/bash/br"
[ -f "$BROOT_LAUNCHER" ] && source "$BROOT_LAUNCHER"
unset BROOT_LAUNCHER
