
alias ls='ls -G --color'
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

alias ll='ls -lh'
alias l='ls -l'

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

type tmuxinator >/dev/null 2>&1 && alias mux=tmuxinator
type make >/dev/null 2>&1 && alias mak='make -j 16'
type nvim >/dev/null 2>&1 && alias vim='nvim'
type pip3 >/dev/null 2>&1 && alias pip=pip3

# fzf
if type rg>/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg -i -g "" --files'
elif type ag>/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='ag -g ""'
elif type fd>/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f'
fi
export FZF_DEFAULT_OPTS="--preview 'head -60 {}'"

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

[ -f ~/perl5/perlbrew/etc/bashrc ] && source ~/perl5/perlbrew/etc/bashrc

if [ -f /usr/libexec/java_home ]; then
    export JAVA_HOME=`/usr/libexec/java_home`
    export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
    export PATH="$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin"
fi

if type go >/dev/null 2>&1 && [ -z $GOPATH ]; then
    export GOPATH=$HOME/gowork
    export PATH="/usr/local/bin:$PATH:$GOPATH/bin:/usr/local/opt/go/libexec/bin"
fi
if [ -d /usr/local/opt/findutils/libexec/gnubin ]; then
    PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
fi

test -d ~/bin && export PATH="$PATH:~/bin"
type thefuck >/dev/null 2>&1 && eval $(thefuck --alias)
test -e "~/.iterm2_shell_integration.zsh" && source "~/.iterm2_shell_integration.zsh"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
type kubectl >/dev/null 2>&1 && source <(kubectl completion bash)
