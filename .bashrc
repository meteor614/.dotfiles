
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

alias 。。=..

if type exa>/dev/null 2>&1; then
    alias ll='exa -l'
    alias l='exa -l'
    alias la='exa -la'
    alias k='exa -l'
    alias ls='exa'
else
    alias ls='ls -G --color'
    alias ll='ls -lh'
    alias l='ls -l'
fi

export PS1='[\u@\h \w]$ '

# git icdiff
if type icdiff>/dev/null 2>&1; then
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

# fzf
if type rg>/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg -i -g "" --files'
elif type ag>/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='ag -g ""'
elif type fd>/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
fi
if type bat>/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
else
    export FZF_DEFAULT_OPTS="--preview 'head -60 {}'"
fi

export SVN_EDITOR='vim'
export EDITOR='vim'
export TERM=xterm-256color

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

#export HOMEBREW_BOTTLE_DOMAIN=
#export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.cloud.tencent.com/homebrew-bottles
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles

[ -f ~/perl5/perlbrew/etc/bashrc ] && source ~/perl5/perlbrew/etc/bashrc

if [ -f /usr/libexec/java_home ]; then
    export JAVA_HOME=`/usr/libexec/java_home`
    if [ "$JAVA_HOME" =~ '.*JavaApplet.*' ]; then
        export JAVA_HOME=`/usr/libexec/java_home -V 2>&1|grep 'SE'|head -1|awk -F'\" ' '{print $3}'`
    fi
    export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
    export PATH="$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin"
fi

if [ -d /opt/bin ]; then
    export PATH="/opt/bin:$PATH"
fi
if [ -d /usr/local/bin ]; then
    export PATH="/usr/local/bin:$PATH"
fi
if [ -d /usr/local/opt/gnu-getopt/bin ]; then
    export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"
fi
if [ -d /usr/local/opt/node/bin ]; then
    export PATH="/usr/local/opt/node/bin:$PATH"
fi
if [ -d /usr/local/opt/python@3.10/bin ]; then
    export PATH="/usr/local/opt/python@3.10/bin:$PATH"
fi

if type go >/dev/null 2>&1 && [ -z $GOPATH ]; then
    export GOPATH=$HOME/gowork
    export PATH="$PATH:$GOPATH/bin:/usr/local/opt/go/libexec/bin"
    export GOPROXY=https://mirrors.tencent.com/go/
fi
if [ -d /usr/local/opt/findutils/libexec/gnubin ]; then
    PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
fi

if [ -d /volume1/\@optware/bin/ ]; then
    export PATH="$PATH:/volume1/@optware/bin"
fi
if [ -d /opt/homebrew/bin ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

test -d $HOME/bin && export PATH="$PATH:$HOME/bin"
test -d $HOME/.local/bin && export PATH="$PATH:$HOME/.local/bin"
type thefuck >/dev/null 2>&1 && eval $(thefuck --alias)
test -e "~/.iterm2_shell_integration.zsh" && source "~/.iterm2_shell_integration.zsh"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
type kubectl >/dev/null 2>&1 && source <(kubectl completion bash)

if [ -f /Applications/WeTERM.app/Contents/Resources/app/external/ssh ]; then
    alias mnet="/Applications/WeTERM.app/Contents/Resources/app/external/ssh -p 36000 -U `whoami`@csig.mnet2.com"
fi

type tmuxinator >/dev/null 2>&1 && alias mux=tmuxinator
type make >/dev/null 2>&1 && alias mak='make -j 16'
if type lvim >/dev/null 2>&1; then
    alias vim='lvim' 
else
    type nvim >/dev/null 2>&1 && alias vim='nvim'
fi
type pip3 >/dev/null 2>&1 && alias pip=pip3
type watch >/dev/null 2>&1 && alias watch='watch -c'
type docker >/dev/null 2>&1 && alias docker='sudo -E docker'
type dtruss >/dev/null 2>&1 && ! type strace >/dev/null 2>&1 && alias strace='dtruss'

