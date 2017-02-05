################################################################################
#                                                                              #
#   Author: Mike 8a                                                            #
#   Description: Small shell configs                                           #
#                                                                              #
#                                     -`                                       #
#                     ...            .o+`                                      #
#                  .+++s+   .h`.    `ooo/                                      #
#                 `+++%++  .h+++   `+oooo:                                     #
#                 +++o+++ .hhs++. `+oooooo:                                    #
#                 +s%%so%.hohhoo'  'oooooo+:                                   #
#                 `+ooohs+h+sh++`/:  ++oooo+:                                  #
#                  hh+o+hoso+h+`/++++.+++++++:                                 #
#                   `+h+++h.+ `/++++++++++++++:                                #
#                            `/+++ooooooooooooo/`                              #
#                           ./ooosssso++osssssso+`                             #
#                          .oossssso-````/osssss::`                            #
#                         -osssssso.      :ssss``to.                           #
#                        :osssssss/  Mike  osssl   +                           #
#                       /ossssssss/   8a   +sssslb                             #
#                     `/ossssso+/:-        -:/+ossss'.-                        #
#                    `+sso+:-`                 `.-/+oso:                       #
#                   `++:.                           `-/+/                      #
#                   .`                                 `/                      #
#                                                                              #
################################################################################

# Path to the bash it configuration
if [[ -d "$HOME/.bash-it" ]]; then
    export BASH_IT="$HOME/.bash-it"
elif [[ -d "$HOME/.bash_it" ]]; then
    export BASH_IT="$HOME/.bash_it"
fi

# Lock and Load a custom theme file
# location ~/.bash_it/themes/
export BASH_IT_THEME='bakke'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
# export SHORT_HOSTNAME=$(hostname -s)

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.

################################################################################
#                               Vim c-s compatibility                          #
stty -ixon                                                                     #
################################################################################

################################################################################
#                         Make some dir that I normally use                    #
################################################################################
if [[ ! -d $HOME/.local/ ]]; then
    mkdir -p $HOME/.local/bin
    mkdir -p $HOME/.local/lib
    mkdir -p $HOME/.local/share

    export PATH="$HOME/.local/bin/:$PATH"
fi

if [[ -f $HOME/.local/lib/pythonstartup.py ]]; then
    export PYTHONSTARTUP="$HOME/.local/lib/pythonstartup.py"
fi

if [[ -d $HOME/.local/neovim/bin ]]; then
    export PATH="$HOME/.local/neovim/bin:$PATH"
fi

################################################################################
#                       Load the settings, alias and framework                 #
################################################################################
# Load host settings
if [[ -f ~/.shell_settings ]]; then
    source ~/.shell_settings
fi

# Load Bash It after set host settings
if [[ -f "$BASH_IT/bash_it.sh" ]]; then
    source $BASH_IT/bash_it.sh
fi

# Load alias after bash-it to give them higher priority
if [[ -f ~/.shell_alias ]]; then
    source ~/.shell_alias
fi
