#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1090,SC1117

! hash is_wsl 2>/dev/null && is_wsl() { return 0; }
! hash is_64bits 2>/dev/null && is_64bits() { return 0; }
! hash is_windows 2>/dev/null && is_windows() { return 0; }

# Set vi keys
set -o vi

# Make backspace delete in a sane way
stty erase '^?'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s autocd
shopt -s globstar
shopt -s cdspell
shopt -s direxpand
shopt -s dirspell
shopt -s nocaseglob

# HISTCONTROL=ignoreboth
HISTCONTROL='erasedups:ignoreboth'
HISTFILESIZE=9999
HISTSIZE=9999
# PROMPT_COMMAND='history -a'
shopt -s histappend histverify

# Path to the bash it configuration
if [[ -d "$HOME/.bash-it" ]]; then
    export BASH_IT="$HOME/.bash-it"
elif [[ -d "$HOME/.bash_it" ]]; then
    export BASH_IT="$HOME/.bash_it"
else

    export black="\[\e[0;30m\]"
    export red="\[\e[0;31m\]"
    export green="\[\e[0;32m\]"
    export yellow="\[\e[0;33m\]"
    export blue="\[\e[0;34m\]"
    export magenta="\[\e[0;35m\]"
    export cyan="\[\e[0;36m\]"
    export white="\[\e[0;37m\]"
    export orange="\[\e[0;91m\]"
    export normal="\[\e[0m\]"
    export reset_color="\[\e[39m\]"

    # These colors are meant to be used with `echo -e`
    export echo_black="\033[0;30m"
    export echo_red="\033[0;31m"
    export echo_green="\033[0;32m"
    export echo_yellow="\033[0;33m"
    export echo_blue="\033[0;34m"
    export echo_magenta="\033[0;35m"
    export echo_cyan="\033[0;36m"
    export echo_white="\033[0;37;1m"
    export echo_orange="\033[0;91m"
    export echo_normal="\033[0m"
    export echo_reset_color="\033[39m"

fi

# location ~/.bash_it/themes/
# Load it just in case it's not defined yet
if is_windows || ! is_64bits; then
    [[ -z $BASH_IT_THEME ]] && export BASH_IT_THEME='demula'
else
    [[ -z $BASH_IT_THEME ]] && export BASH_IT_THEME='bakke'
fi

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# Your place for hosting Git repos. I use this for private repos.
# [[ -z $GIT_HOSTING ]] &&  export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
# export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
# export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
# [[ -z $SCM_CHECK ]] && export SCM_CHECK=true

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
# export SHORT_HOSTNAME=$(hostname -s)

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
# export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).

# INFO: Use enviroment variables to avoid shellcheck errors in bash_completion file
if ! shopt -oq posix; then

    COMPLETIONS="/usr/share/bash-completion"
    if [ -f "$COMPLETIONS/bash_completion" ]; then
        # shellcheck disable=SC1091
        source "$COMPLETIONS/bash_completion"
    fi

    COMPLETIONS="/etc"
    if [ -f "$COMPLETIONS/bash_completion" ]; then
        # shellcheck disable=SC1091
        source "$COMPLETIONS/bash_completion"
    fi
fi

# # pip bash completion start
# if hash pip 2>/dev/null || hash pip2 2>/dev/null || hash pip3 2>/dev/null; then
#     hash pip 2>/dev/null && eval "$(pip completion --bash)"
#     hash pip2 2>/dev/null && eval "$(pip2 completion --bash 2>/dev/null)"
#     hash pip3 2>/dev/null && eval "$(pip3 completion --bash)"
# fi
# # pip bash completion end

if hash fzf 2>/dev/null; then
    # shellcheck disable=SC1091
    [[ -f "$HOME/.fzf.bash" ]] && source "$HOME/.fzf.bash"
fi

if [[ -f "$BASH_IT/bash_it.sh" ]]; then
    # shellcheck disable=SC1091
    source "$BASH_IT/bash_it.sh"
else

    __git_info() {
        if hash git 2>/dev/null; then
            local branch changes stash info
            # shellcheck disable=SC2063
            branch="$(git branch 2>/dev/null | grep '^*' | awk '{$1=""; print $0}')"
            if [[ -n $branch ]]; then
                branch="${echo_white}${echo_blue}${branch}"
                changes="$(git diff --shortstat 2>/dev/null | awk '{
                    printf "%s~%d %s+%d %s-%d%s", ENVIRON["echo_yellow"], $1, ENVIRON["echo_green"], $4, ENVIRON["echo_red"], $6, ENVIRON["echo_blue"];
                }')"
                to_commit="$(git diff --cached --shortstat 2>/dev/null | awk '{
                    printf "%s*%d", ENVIRON["echo_magenta"], $1;
                }')"
                stash="$(git stash list 2>/dev/null | wc -l)"
                if [[ $stash -ne 0 ]]; then
                    stash="${echo_yellow}{$stash}"
                else
                    stash=''
                fi
                info="${echo_blue}|"
                [[ -n $branch ]] && info="$info ${echo_reset_color}$branch${echo_reset_color}"
                [[ -n $to_commit ]] && info="$info ${echo_reset_color}$to_commit${echo_reset_color}"
                [[ -n $changes ]] && info="$info ${echo_reset_color}$changes${echo_reset_color}"
                [[ -n $stash ]] && info="$info ${echo_reset_color}$stash${echo_reset_color}"
                info="$info ${echo_blue}|${echo_reset_color} "
                echo -e "$info"
            fi
        fi
    }

    __venv() {
        if [[ -n $VIRTUAL_ENV ]]; then
            local version
            version="$(python --version | awk '{print $2}')"
            echo -e "${echo_white}(${VIRTUAL_ENV##*/} 🐍 ${version})${echo_reset_color} "
        fi
    }

    __proxy() {
        # shellcheck disable=SC2154
        if [[ -n $http_proxy ]]; then
            echo -e "${echo_green}🌐${echo_reset_color} "
        fi
    }

    __user() {
        if [[ $EUID -eq 0 ]]; then
            echo -e "${echo_red}$USER${echo_reset_color} at "
        fi
    }

    __exit_code() {
        local rc=$?
        # NOTE: ignore send to background and <CTRL-c> exit codes
        if [[ $rc -ne 0 ]] && [[ $rc -ne 148 ]] && [[ rc -ne 130 ]]; then
            echo -e " ${echo_red}❌${echo_reset_color} "
        fi
    }

    __schroot_name() {
        if [[ -n ${SCHROOT_CHROOT_NAME} ]]; then
            echo -e "${echo_red}(${SCHROOT_CHROOT_NAME})${echo_reset_color} "
        fi
    }

    # PS1="\n$(__schroot_name)\$(__exit_code)$(__user)${cyan}\h${reset_color}: ${yellow}\w${reset_color} ${magenta}J:\j${reset_color} \$(__proxy)\$(__venv)\$(__git_info) \n→ "

    _prompt_command() {
        # EXIT_CODE=$?

        PS1="\n"
        PS1+="$(__schroot_name)"
        PS1+="$(__exit_code)"
        PS1+="$(__user)"
        PS1+="${cyan}\h${reset_color}: "
        PS1+="${yellow}\w${reset_color} "
        PS1+="${magenta}J:\j${reset_color} "
        PS1+="$(__proxy)"
        PS1+="$(__venv)"
        PS1+="$(__git_info) "
        PS1+="\n$ "
    }
    PROMPT_COMMAND=_prompt_command

fi

if hash kitty 2>/dev/null; then
    source <(kitty + complete setup bash)
fi

if hash tmux 2>/dev/null; then
    bind '"\C-a":"tmux a || tmux new -s main\n"'
fi

function toggleProxy() {
    # shellcheck disable=SC2154
    if [[ -n $http_proxy ]]; then
        unset "http_proxy"
        unset "https_proxy"
        unset "ftp_proxy"
        unset "socks_proxy"
        unset "no_proxy"
        export PROXY_DISABLE=1
        echo -e " ${echo_yellow}Proxy disable${echo_reset_color}"
    elif [[ -f "$HOME/.config/shell/host/proxy.sh" ]]; then
        # shellcheck disable=SC1090,SC1091
        source "$HOME/.config/shell/host/proxy.sh"
        unset PROXY_DISABLE
        echo -e " ${echo_green}Proxy enable${echo_reset_color}"
    else
        echo -e " ${echo_red}Missing proxy file !!${echo_reset_color}"
    fi
}

#######################################################################
#                          Bash Completion                            #
#######################################################################

if [[ -f /etc/bash_completion ]]; then
    # shellcheck disable=SC1091
    source /etc/bash_completion
elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
    # shellcheck disable=SC1091
    source /usr/share/bash-completion/bash_completion
else
    completion_dir=''

    if [[ -d /usr/share/bash-completion/completions ]]; then
        completion_dir=/usr/share/bash-completion/completions
    elif [[ -d /etc/bash_completion.d/ ]]; then
        completion_dir=/etc/bash_completion.d/
    fi

    if [[ -n $completion_dir ]]; then
        for c in "$completion_dir"/*; do
            source "$c" 2>/dev/null
        done
    fi
    unset completion_dir
fi
