
alias ls='ls -G --color'
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

alias ll='ls -lh'
alias l='ls -l'
#alias vim='nvim'

export PS1='[\u@\h \w]$ '

# git icdiff
if type icdiff>/dev/null 2>&1; then
    alias gd='git icdiff'
    alias gdca='git icdiff --cached'
    alias gdcw='git icdiff --cached --word-diff'
    alias gdw='git icdiff --word-diff'
fi

alias mux='tmuxinator'
alias mak='make -j 10'

type nvim >/dev/null 2>&1 && alias vim='nvim'

# fzf
if type rg>/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg -i -g "" --files'
elif type ag>/dev/null 2>&1; then
    export FZF_DEFAULT_ COMMAND='ag -g ""'
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
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ -f /usr/libexec/java_home ]; then
    export JAVA_HOME=`/usr/libexec/java_home`
    export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
    export PATH="$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin"
fi

test -d ~/bin && export PATH="$PATH:~/bin"
type thefuck >/dev/null 2>&1 && eval $(thefuck --alias)
test -e "~/.iterm2_shell_integration.zsh" && source "~/.iterm2_shell_integration.zsh"

