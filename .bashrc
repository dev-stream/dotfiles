#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set to superior editing mode
set -o vi

# keybinds
bind -x '"\C-l":clear' # old habit (it's better to use `c` alias)

# bash-completion similar to zsh
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

export MSYS=winsymlinks:nativestrict # Cygwin creates symlinks as native Windows symlinks on filesystems and OS versions supporting them.

# config

export XDG_DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}"
export NVIM_APPNAME=lazyvim240309
export NVIM_SILENT= # NVIM_SILENT= (nil in neovim)
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$TEMP"}"

export BROWSER="vivaldi"

# directories
export REPOS="$HOME/Repos"
export GITUSER="dev-stream"
export GHREPOS="$REPOS/github.com/$GITUSER"
export DOTFILES="$GHREPOS/dotfiles"
export SCRIPTS="$DOTFILES/scripts"
export SECOND_BRAIN="$HOME/garden"

# Go related. In general all executables and scripts go in .local/bin
export GOBIN="$HOME/.local/bin"
export GOPRIVATE="github.com/$GITUSER/*,gitlab.com/$GITUSER/*"
export GOPATH="$HOME/go/"

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~
# function from Arch Wiki, to prevent adding directories multiple times

set_path() {

	# Check if user id is 1000 or higher
	[ "$(id -u)" -ge 1000 ] || return

	for i in "$@"; do
		# Check if the directory exists
		[ -d "$i" ] || continue

		# Check if it is not already in your $PATH.
		echo "$PATH" | grep -Eq "(^|:)$i(:|$)" && continue

		# Then append it to $PATH and export it
		export PATH="${PATH}:$i"
	done
}

set_path "$HOME"/.local/bin

# cargo
set_path $(cygpath -u $USERPROFILE)/.cargo/bin

# dotnet
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_ROOT=/usr/share/dotnet
export DOTNET_INSTALL_DIR=$DOTNET_ROOT
set_path $(cygpath -u $DOTNET_ROOT)
set_path $(cygpath -u $DOTNET_ROOT/tools)
alias dotnet_tool_list='dotnet tool list --tool-path $DOTNET_ROOT/tools'

# https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path
# PATH="${PATH:+${PATH}:}~/opt/bin"   # appending
# PATH="~/opt/bin${PATH:+:${PATH}}"   # prepending

PATH="${PATH:+${PATH}:}"$SCRIPTS":"$HOME"/.local/bin"          # appending
PATH="${PATH:+${PATH}:}"$(cygpath -u $USERPROFILE/scoop/shims) # appending
# lazygit needs system32
PATH="${PATH:+${PATH}:}"/c/WINDOWS/system32 # appending

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~
# TODO write code in your favorite language to sanitise the history
export HISTFILE=~/.histfile
export HISTSIZE=25000
export SAVEHIST=25000
# Don't put duplicate lines in the history
export HISTCONTROL=ignoredups:erasedups:ignorespace
# Don't add mistyped commands to the history
export PROMPT_COMMAND='LAST_COMMAND_EXIT=$? && history -a && test 127 -eq $LAST_COMMAND_EXIT && head -n -2 $HISTFILE >${HISTFILE}_temp && mv ${HISTFILE}_temp $HISTFILE'

# ~~~~~~~~~~~~~~~ Functions ~~~~~~~~~~~~~~~~~~~~~~~~

# This function is taken from rwxrob

clone() {
	local repo="$1" user
	local repo="${repo#https://github.com/}"
	local repo="${repo#git@github.com:}"
	if [[ $repo =~ / ]]; then
		user="${repo%%/*}"
	else
		user="$GITUSER"
		[[ -z "$user" ]] && user="$USER"
	fi
	local name="${repo##*/}"
	local userd="$REPOS/github.com/$user"
	local path="$userd/$name"
	[[ -d "$path" ]] && cd "$path" && return
	mkdir -p "$userd"
	cd "$userd"
	echo gh repo clone "$user/$name" -- --recurse-submodule
	gh repo clone "$user/$name" -- --recurse-submodule
	cd "$name"
} && export -f clone

# ~~~~~~~~~~~~~~~ Prompt ~~~~~~~~~~~~~~~~~~~~~~~~

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
# Explicitly unset color (default anyhow). Use 1 to set it.
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_DESCRIBE_STYLE="branch"
export GIT_PS1_SHOWUPSTREAM="auto git"

# colorized prompt
[ -f "$XDG_CONFIG_HOME/bash/gitprompt.sh" ] &&
	source "$XDG_CONFIG_HOME/bash/gitprompt.sh" &&
	export PROMPT_COMMAND=$PROMPT_COMMAND';__git_ps1 "\[\e[33m\]\u\[\e[0m\]@\[\e[34m\]\h\[\e[0m\]:\[\e[35m\]\W\[\e[0m\]" " \n$ "'

# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~

alias v=nvim
alias vim=nvim

# cd
alias scripts='cd $SCRIPTS'
alias dot='cd $GHREPOS/dotfiles'
alias repos='cd $REPOS'
alias cdgo='cd $GHREPOS/go/'

# ls
alias ls='ls --color=auto'
alias ll='ls -la'
# alias la='exa -laghm@ --all --icons --git --color=always'
alias la='ls -lathr'

# finds all files recursively and sorts by last modification, ignore hidden files
alias last='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'

alias c="clear" # better than ctrl-l
alias e='exit'
alias syu='pacman -Syu'

# git
alias gp='git pull'
alias gs='git status'
alias lg='lazygit'

# ricing
alias eb='dot && v ~/.bashrc'
alias ev='cd $XDG_CONFIG_HOME/$NVIM_APPNAME && v'
alias sbr='echo "BASH_LAST_DIR=$PWD" >~/.bash_lastdir && dot && ./setup && exec bash --login -i'
if [[ -f ~/.bash_lastdir ]]; then
	source ~/.bash_lastdir
	cd $BASH_LAST_DIR
fi

# vim & second brain
alias sb="cd \$SECOND_BRAIN"
alias in="cd \$SECOND_BRAIN/0-inbox/"
alias vbn='python ~/git/python/brainfile.py'

# edit env variables
export VISUAL="nvim --cmd 'let g:NVIM_SILENT=1'"
export EDITOR=$VISUAL

# fzf aliases
# use fp to do a fzf search and preview the files

# Taken from tokyonight.nvim/lua/tokyonight/extra/fzf.lua
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#c0caf5,bg:#1a1b26,hl:#ff9e64
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#ff9e64
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a'

export FZF_DEFAULT_COMMAND='fd --path-separator // --type file --strip-cwd-prefix --hidden --follow --exclude .git'
alias fp='fzf --preview "bat --style=numbers --color=always --line-range :500 {}"' # fd has path-separator

# search for a file with fzf and open it in vim
alias vf='v $(fp)'

# grep with rg and open it in vim
alias vr='rfv'

# sourcing
# source "$HOME/.privaterc"

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash
