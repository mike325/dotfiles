#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1090,SC1117

[[ ! -d $HOME/.local/share/completions/ ]] && mkdir -p $HOME/.local/share/completions/

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
    export purple="\[\e[0;35m\]"
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
    export echo_purple="\033[0;35m"
    export echo_cyan="\033[0;36m"
    export echo_white="\033[0;37;1m"
    export echo_orange="\033[0;91m"
    export echo_normal="\033[0m"
    export echo_reset_color="\033[39m"

fi

function error_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$msg" 1>&2
    else
        printf "[X] Error:\t %s\n" "$msg" 1>&2
    fi
}

function warn_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$msg"
    else
        printf "[!] Warning:\t %s\n" "$msg"
    fi
}

function status_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s\n" "$msg"
    else
        printf "[*] Info:\t %s\n" "$msg"
    fi
}

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

if hash fzf 2>/dev/null; then
    # shellcheck disable=SC1091
    [[ -f "$HOME/.fzf.bash" ]] && source "$HOME/.fzf.bash"
fi

if [[ -f "$BASH_IT/bash_it.sh" ]]; then
    # shellcheck disable=SC1091
    source "$BASH_IT/bash_it.sh"
else

    # TODO: May migrate this logic/function to python or go to improve performance and better handle output
    __git_info() {
        if hash git 2>/dev/null; then
            local branch changes stash info
            # shellcheck disable=SC2063
            branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
            if [[ -n $branch ]]; then
                if [[ ${#branch} -gt 20 ]]; then
                    local fer_issue_br_regex="^[ ]?[A-Za-z]+[/-]([A-Za-z]+[/-][0-9]+[/-])"
                    local issue_br_regex="^[ ]?([A-Za-z]+[/-][0-9]+[-/])"
                    if [[ $branch =~ $fer_issue_br_regex ]]; then
                        local index
                        index="$(echo "$branch" | command grep -oE "$fer_issue_br_regex")"
                        branch=" $(echo "$branch" | awk "{print substr(\$1,${#index}+1)}")"
                    elif [[ $branch =~ $issue_br_regex ]]; then
                        local index
                        index="$(echo "$branch" | command grep -oE "$issue_br_regex")"
                        branch=" $(echo "$branch" | awk "{print substr(\$1,${#index}+1)}")"
                    fi
                fi
                changes="$(git diff --shortstat 2>/dev/null | awk '{
                    printf "%s*%d %s+%d %s-%d%s", ENVIRON["echo_yellow"], $1, ENVIRON["echo_green"], $4, ENVIRON["echo_red"], $6, ENVIRON["echo_blue"];
                }')"
                to_commit="$(git diff --cached --shortstat 2>/dev/null | awk '{
                    printf "%s*%d", ENVIRON["echo_magenta"], $1;
                }')"
                # stash="$(git stash list 2>/dev/null | wc -l)"
                # if [[ $stash -ne 0 ]]; then
                #     stash="${echo_yellow}{${stash##* }}"
                # else
                #     stash=''
                # fi
                info="${echo_blue}|${echo_reset_color}"
                # TODO: Find another icon to represent git branch
                if [[ -z $NO_COOL_FONTS ]]; then
                    info="$info ${echo_white}${echo_reset_color}"
                    info="$info ${echo_blue}$branch${echo_reset_color}"
                else
                    info="$info ${echo_blue}{$branch}${echo_reset_color}"
                fi
                [[ -n $to_commit ]] && info="$info $to_commit${echo_reset_color}"
                [[ -n $changes ]] && info="$info $changes${echo_reset_color}"
                [[ -n $stash ]] && info="$info $stash${echo_reset_color}"
                info="$info ${echo_blue}|${echo_reset_color} "
                echo -e "$info"
            fi
        fi
    }

    __venv() {
        # TODO: May should cache the version and clear cache once we deactivate/change virtual env
        if [[ -n $VIRTUAL_ENV ]]; then
            ENV_VERSION="$(python --version | awk '{print $2}')"
            export ENV_VERSION="${ENV_VERSION%% *}"
            env_name="${VIRTUAL_ENV##*/}"
        elif [[ -n $CONDA_DEFAULT_ENV ]]; then
            ENV_VERSION="$($CONDA_PYTHON_EXE --version | awk '{print $2}')"
            export ENV_VERSION="${ENV_VERSION%% *}"
            env_name="$CONDA_DEFAULT_ENV"
        fi

        if [[ -n $ENV_VERSION ]]; then
            echo -e " ${echo_white}(${env_name} 🐍 ${ENV_VERSION})${echo_reset_color} "
        else
            unset ENV_VERSION 2>/dev/null
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
        # ➤
        # ▶
        # $
        # ❯
        # »
        # ❯
        local rc="$1"
        # NOTE: ignore send to background and <CTRL-c> exit codes
        if [[ $rc -ne 0 ]] && [[ $rc -ne 148 ]] && [[ $rc -ne 130 ]]; then
            echo -e "${echo_red}❯${echo_reset_color} "
        else
            echo "❯ "
        fi
    }

    __schroot_name() {
        if [[ -n ${SCHROOT_CHROOT_NAME} ]]; then
            echo -e "${echo_red}(${SCHROOT_CHROOT_NAME})${echo_reset_color} "
        fi
    }

    # __cwd() {
    #     local _cwd
    #     _cwd="$(pwd -P)"
    #     _cwd="${_cwd/$HOME/~}"
    #     if [[ ${#_cwd} -gt $((COLUMNS / 2)) ]]; then
    #         local i=2
    #         while [[ ${#_cwd} -gt $((COLUMNS / 2)) ]] || [[ -z $(echo "$_cwd" | awk -F/ "{ print substr(\$$i,1,1)}") ]]; do
    #             _cwd="$(echo "$_cwd" | awk -F/ "BEGIN { OFS = FS } { \$$i = substr(\$$i,1,1) } {print}")"
    #             i=$((i + 1))
    #         done
    #         echo -e "${echo_yellow}${_cwd}${echo_reset_color} "
    #     else
    #         echo -e "${echo_yellow}\w${echo_reset_color} "
    #     fi
    # }

    function __cc_view() {
        if [[ -n $CLEARCASE_ROOT ]]; then
            echo -e "${echo_red}($(echo "$CLEARCASE_ROOT" | awk -F/ -v pat="${USER}_at_" '{gsub(pat, "", $3 ) ; print $3}'))${echo_reset_color}"
        fi
    }

    # TODO: This function should short long components automatically
    # TODO: Add support for custom host prompt segments
    _prompt_command() {
        local EXIT_CODE="$?"

        PS1="\n"
        # PS1+="$(__schroot_name)"
        PS1+="$(__user)"
        PS1+="${cyan}\h${reset_color}: "
        PS1+="${yellow}\w${reset_color} "
        # PS1+="$(__cwd)"
        PS1+="${magenta}J:\j${reset_color} "
        PS1+="$(__proxy)"
        PS1+="$(__venv)"
        PS1+="$(__cc_view) "
        PS1+="$(__git_info) "
        PS1+="\n$(__exit_code "$EXIT_CODE")"
        # PS1+="\n$ "
    }
    PROMPT_COMMAND=_prompt_command

fi

if hash tmux 2>/dev/null; then
    bind '"\C-a":"tmux attach -t main || tmux new -s main\n"'
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

# # pip bash completion start
# if hash pip 2>/dev/null || hash pip2 2>/dev/null || hash pip3 2>/dev/null; then
#     hash pip 2>/dev/null && eval "$(pip completion --bash)"
#     hash pip2 2>/dev/null && eval "$(pip2 completion --bash 2>/dev/null)"
#     hash pip3 2>/dev/null && eval "$(pip3 completion --bash)"
# fi
# # pip bash completion end

if hash kitty 2>/dev/null; then
    if [[ ! -f $HOME/.local/share/completions/kitty.bash ]]; then
        kitty + complete setup bash >$HOME/.local/share/completions/kitty.bash
    fi
fi

if hash gh 2>/dev/null; then
    eval "$(gh completion --shell bash)"
fi

#######################################################################
#                          Bash Completion                            #
#######################################################################

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then

    if [[ -d "$HOME/.local/share/completions/" ]]; then
        for cfile in "$HOME/.local/share/completions/"*.bash; do
            source "$cfile" 2>/dev/null
        done
    fi

    if [[ -f /etc/bash_completion ]]; then
        # shellcheck disable=SC1091
        source /etc/bash_completion 2>/dev/null
    elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
        # shellcheck disable=SC1091
        source /usr/share/bash-completion/bash_completion 2>/dev/null
    else
        # TODO: This may be too slow in some systems
        completion_dirs=(
            "/usr/share/bash-completion/completions/"
            "/etc/bash_completion.d/"
        )

        for cdir in "${completion_dirs[@]}"; do
            if [[ -d $cdir ]]; then
                for src in "$cdir"/*; do
                    source "$src" 2>/dev/null
                done
            fi
        done
    fi
fi
