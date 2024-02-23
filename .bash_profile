#
# ~/.bash_profile
#

if [ -r ~/.bashrc ]; then
	source ~/.bashrc
fi

export XDG_CONFIG_HOME="$HOME"/.config

source "$XDG_CONFIG_HOME"/bash/git-prompt.sh
