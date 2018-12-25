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
antigen bundle command-not-found

antigen bundle colorize
antigen bundle github
antigen bundle python
antigen bundle rupa/z z.sh
antigen bundle andrewferrier/fzf-z
#antigen bundle z
antigen bundle tysonwolker/iterm-tab-colors
antigen bundle "MichaelAquilina/zsh-you-should-use"

antigen bundle zsh-history-substring-search
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle supercrabtree/k
antigen bundle Vifon/deer

antigen bundle ssh-agent
antigen bundle zsh-plugin-ssh
antigen bundle popstas/zsh-command-time
antigen bundle "greymd/tmux-xpanes"

# OS specific plugins
if [[ $CURRENT_OS == 'OS X' ]]; then
    antigen bundle brew
    antigen bundle brew-cask
    antigen bundle gem
    antigen bundle osx
fi

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
#antigen theme robbyrussell

antigen apply

# setup for deer
autoload -U deer
zle -N deer

# Initialize command prompt
export PS1="%{$fg[magenta]%}%n%{$fg[green]%} %{$fg[cyan]%}%~%{$fg[green]%}> "
# set RPROMPT only version >= 5.0
if (echo ${ZSH_VERSION} | awk -F'.' '!($1>=5){exit 1}') then
    export RPROMPT='%{$fg_bold[red]%}%(?..%?)%{$reset_color%}$(git_prompt_info)$(git_prompt_status)%{$reset_color%}'
fi

ZSH_THEME_GIT_PROMPT_PREFIX=" "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?"

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

