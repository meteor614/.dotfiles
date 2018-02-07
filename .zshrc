# Antigen: https://github.com/zsh-users/antigen
ANTIGEN="$HOME/.local/bin/antigen.zsh"

# Install antigen.zsh if not exist
if [ ! -f "$ANTIGEN" ]; then
	echo "Installing antigen ..."
	[ ! -d "$HOME/.local" ] && mkdir -p "$HOME/.local" 2> /dev/null
	[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin" 2> /dev/null
	[ ! -f "$HOME/.z" ] && touch "$HOME/.z"
	URL="http://git.io/antigen"
	TMPFILE="/tmp/antigen.zsh"
	if [ -x "$(which curl)" ]; then
		curl -L "$URL" -o "$TMPFILE" 
	elif [ -x "$(which wget)" ]; then
		wget "$URL" -O "$TMPFILE" 
	else
		echo "ERROR: please install curl or wget before installation !!"
		exit
	fi
	if [ ! $? -eq 0 ]; then
		echo ""
		echo "ERROR: downloading antigen.zsh ($URL) failed !!"
		exit
	fi;
	echo "move $TMPFILE to $ANTIGEN"
	mv "$TMPFILE" "$ANTIGEN"
fi


# Initialize antigen
source "$ANTIGEN"

# Load local bash/zsh compatible settings
[ -f "$HOME/.local/etc/init.sh" ] && source "$HOME/.local/etc/init.sh"


# Initialize oh-my-zsh
antigen use oh-my-zsh

# default bundles
# visit https://github.com/unixorn/awesome-zsh-plugins
antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle svn-fast-info
antigen bundle command-not-find

antigen bundle colorize
antigen bundle github
antigen bundle python
antigen bundle rupa/z z.sh
#antigen bundle z

antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle supercrabtree/k
antigen bundle Vifon/deer

antigen bundle ssh-agent
antigen bundle popstas/zsh-command-time

# OS specific plugins
if [[ $CURRENT_OS == 'OS X' ]]; then
    antigen bundle brew
    antigen bundle brew-cask
    antigen bundle gem
    antigen bundle osx
fi

# uncomment the line below to enable theme
# antigen theme fishy


# check login shell
if [[ -o login ]]; then
	[ -f "$HOME/.local/etc/login.sh" ] && source "$HOME/.local/etc/login.sh"
	[ -f "$HOME/.local/etc/login.zsh" ] && source "$HOME/.local/etc/login.zsh"
fi

# syntax color definition
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

typeset -A ZSH_HIGHLIGHT_STYLES

# ZSH_HIGHLIGHT_STYLES[command]=fg=white,bold
# ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'

ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=009
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=009,standout
ZSH_HIGHLIGHT_STYLES[alias]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[builtin]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[function]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[command]=fg=white,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=white,underline
ZSH_HIGHLIGHT_STYLES[commandseparator]=none
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=009
ZSH_HIGHLIGHT_STYLES[path]=fg=214,underline
ZSH_HIGHLIGHT_STYLES[globbing]=fg=063
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=white,underline
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[assign]=none

# load local config
[ -f "$HOME/.local/etc/config.zsh" ] && source "$HOME/.local/etc/config.zsh" 
[ -f "$HOME/.local/etc/local.zsh" ] && source "$HOME/.local/etc/local.zsh"

# enable syntax highlighting
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

# setup for deer
autoload -U deer
zle -N deer

# default keymap
bindkey -s '\ee' 'vim\n'
bindkey '\eh' backward-char
bindkey '\el' forward-char
bindkey '\ej' down-line-or-history
bindkey '\ek' up-line-or-history
# bindkey '\eu' undo
bindkey '\eH' backward-word
bindkey '\eL' forward-word
bindkey '\eJ' beginning-of-line
bindkey '\eK' end-of-line

bindkey -s '\eo' 'cd ..\n'
bindkey -s '\e;' 'll\n'

bindkey '\e[1;3D' backward-word
bindkey '\e[1;3C' forward-word
bindkey '\e[1;3A' beginning-of-line
bindkey '\e[1;3B' end-of-line

bindkey '\ev' deer

#alias ls='ls -G --color'
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

alias ll='ls -lh'
alias l='ls -l'
alias -s gz='tar -xzvf'
alias -s tgz='tar -xzvf'
alias -s zip='unzip'
alias -s bz2='tar -xjvf'

alias vim='nvim'

#export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_DEFAULT_COMMAND='rg -i -g "" --files'
export FZF_DEFAULT_OPTS="--preview 'head -60 {}'"
export SVN_EDITOR='vim'
export EDITOR='vim'
export TERM=xterm-256color

# Initialize command prompt
#export PS1="%n@%m:%~%# "
#export PS1="%{$fg[green]%}[%{$fg[magenta]%}%n%{$fg[green]%}@%{$fg[blue]%}%m%{$fg[green]%}:%{$fg[cyan]%}%~%{$fg[green]%}]$ "
export PS1="%{$fg[green]%}[%{$fg[magenta]%}%n%{$fg[green]%}:%{$fg[cyan]%}%~%{$fg[green]%}]$ "
export RPROMPT="%{$fg[red]%}%(?..%?%1v) %{$fg[yellow]%}%*"

setopt no_nomatch

[ -f ~/perl5/perlbrew/etc/bashrc ] && source ~/perl5/perlbrew/etc/bashrc
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

if [ -f /usr/libexec/java_home ]; then
    export JAVA_HOME=`/usr/libexec/java_home`
    export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
    export PATH="$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin"
fi

type thefuck >/dev/null 2>&1 && eval $(thefuck --alias)
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

