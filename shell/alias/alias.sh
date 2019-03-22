#!/usr/bin/env bash

################################################################################
#                                                                              #
#   Author: Mike 8a                                                            #
#   Description: Some useful alias and functions                               #
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
#                   .`   github.com/mike325/dotfiles   `/                      #
#                                                                              #
################################################################################

################################################################################
#                          Set the default text editor                         #
################################################################################

# Set vi to start as a minimal setup with just settings, mappings and autocmd; 0 plugins

if hash vim 2> /dev/null || hash nvim 2>/dev/null; then
    if hash nvim 2>/dev/null; then
        if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then
            alias cdvi="cd ~/.vim"
            alias cdvim="cd ~/AppData/Local/nvim/"
            # NOTE: This is set inside Neovim settings
            # shellcheck disable=SC2154
            if [[ -z "$nvr" ]]; then
                function nvim() {
                    # NOTE: This is set inside Neovim settings
                    # shellcheck disable=SC2154
                    if [[ -z "$nvr" ]]; then
                        nvim-qt "$@" &
                    else
                        nvim "$@"
                    fi
                }
                export MANPAGER="env MAN_PN=1 vim --cmd 'let g:minimal=0 --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=man  nomodifiable' +MANPAGER -"
                export GIT_PAGER="vim --cmd 'let g:minimal=0' --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=git  nomodifiable' -"
                export EDITOR="vim"
                alias vi="vim --cmd 'let g:minimal=0'"
                alias viu="vim -u NONE"
                # Fucking typos
                alias nvi="nvim"
                alias vnim="nvim"
            else
                export MANPAGER="nvr -cc 'setlocal modifiable' -c 'silent! setlocal  nomodifiable ft=man' --remote-tab -"
                export GIT_PAGER="nvr -cc 'setlocal modifiable' -c 'setlocal ft=git  nomodifiable' --remote-tab -"
                export EDITOR="nvr --remote-tab-wait"
                alias vi="nvr --remote-silent"
                alias vim="nvr --remote-silent"
                alias nvi="nvr --remote-silent"
                alias nvim="nvr --remote-silent"
                alias vnim="nvr --remote-silent"
            fi

        else
            alias cdvi="cd ~/.vim"
            alias cdvim="cd ~/.config/nvim"
            # NOTE: This is set inside Neovim settings
            # shellcheck disable=SC2154
            if [[ -z "$nvr" ]]; then
                export MANPAGER="nvim --cmd 'let g:minimal=0' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal  nomodifiable ft=man' -"
                export GIT_PAGER="nvim --cmd 'let g:minimal=0' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal ft=git  nomodifiable' - "
                export EDITOR="nvim"
                alias vi="nvim --cmd 'let g:minimal=0'"
                alias viu="nvim -u NONE"
                # Fucking typos
                alias nvi="nvim"
                alias vnim="nvim"
            else
                export MANPAGER="nvr -cc 'setlocal modifiable' -c 'silent! setlocal  nomodifiable ft=man' --remote-tab -"
                export GIT_PAGER="nvr -cc 'setlocal modifiable' -c 'setlocal ft=git  nomodifiable' --remote-tab -"
                export EDITOR="nvr --remote-tab-wait"
                alias vi="nvr --remote-silent"
                alias vim="nvr --remote-silent"
                alias nvi="nvr --remote-silent"
                alias nvim="nvr --remote-silent"
                alias vnim="nvr --remote-silent"
            fi
        fi
    else
        alias cdvim="cd ~/.vim"
        alias cdvi="cd ~/.vim"
        export MANPAGER="env MAN_PN=1 vim --cmd 'let g:minimal=0 --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=man  nomodifiable' +MANPAGER -"
        export GIT_PAGER="vim --cmd 'let g:minimal=0' --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=git  nomodifiable' -"
        export EDITOR="vim"

        alias vi="vim --cmd 'let g:minimal=0'"
        alias viu="vim -u NONE"
    fi
fi

################################################################################
#                          Fix my common typos                                 #
################################################################################

alias gti="git"
alias got="git"
alias gut="git"
alias gi="git"

if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then
    alias bim="vim"
    alias cim="vim"
    alias im="vim"
elif hash nvim 2>/dev/null; then
    alias bim="nvim"
    alias cim="nvim"
    alias im="nvim"
else
    alias bim="vim"
    alias cim="vim"
    alias im="vim"
fi

alias bi="vi"
alias ci="vi"

alias py="python"
alias py2="python2"
alias py3="python3"

################################################################################
#                        Some useful shortcuts                                 #
################################################################################

alias sshkey='ssh-keygen -t rsa -b 4096 -C "${MAIL:-mickiller.25@gmail.com}"'

alias user="whoami"
alias j="jobs"

# Check all user process
alias psu='ps -u $USER'

# alias q="exit"
alias cl="clear"
if [[ $EUID -ne 0 ]]; then
    alias turnoff="sudo poweroff"
else
    alias turnoff="poweroff"
fi

if hash clenaswap 2>/dev/null; then
    alias cw="clenaswap"
fi

# Show used ports
alias ports="netstat -tulpn"

# Termux's grep doesn't have color support
if [[ $(uname --all) =~ Android ]]; then
    unalias grep > /dev/null
    alias grep="grep -n"
else
    alias grep="grep --color=auto -n"
fi

alias grepo="grep -o"
alias grepe="grep -E"

alias ls='ls --color'
alias la="ls -hA"
alias l="ls -h"
alias ll="ls -lh"
alias lla="ls -lhA"

# We only want sudo alias when user =! root
[[ $EUID -ne 0 ]] && alias sudo='sudo '

# Magnificent app which corrects your previous console command
# https://github.com/nvbn/thefuck
if hash thefuck 2>/dev/null; then
    # eval "$(thefuck --alias fuck --enable-experimental-instant-mode)"

    eval "$(thefuck --alias)"
    alias please='fuck'

    alias crap="eval \$(thefuck --alias); echo 'f*cks ready'"

    # Yep tons of fucks
    alias guck='fuck'
    alias fukc='fuck'
    alias gukc='fuck'
    alias fuvk='fuck'
else
    :
    # alias fuck='sudo $(history -p \!\!)'
fi

if hash ntfy 2>/dev/null; then
    export AUTO_NTFY_DONE_IGNORE="nvim vi vim screen meld htop top"
    eval "$(ntfy shell-integration)"
fi

if hash cleanswap 2>/dev/null; then
    alias cw="cleanswap"
fi

# laod kernel module for virtualbox
if [[ $EUID -ne 0 ]]; then
    alias vbk="sudo modprobe vboxdrv"
else
    alias vbk="modprobe vboxdrv"
fi

if hash ctags 2>/dev/null; then
    # Get Fucking Tags
    alias gft="ctags -R ."
fi

################################################################################
#                               Systemctl                                      #
################################################################################

if hash systemctl 2>/dev/null; then
    if [[ $EUID -ne 0 ]]; then
        alias sysctl="sudo systemctl"
        alias usysctl="systemctl --user"

        alias ctls="sudo systemctl start"   # Start
        alias ctlr="sudo systemctl restart" # Restart
        alias ctlw="sudo systemctl status"  # shoW
        alias ctlh="sudo systemctl stop"    # Halt
    else
        alias sysctl="systemctl"
        alias usysctl="systemctl --user"

        alias ctls="systemctl start"   # Start
        alias ctlh="systemctl stop"    # Halt
        alias ctlr="systemctl restart" # Restart
        alias ctlw="systemctl status"  # shoW
    fi
fi

################################################################################
#                               Git shortcut                                   #
################################################################################


if hash git 2>/dev/null; then
    alias clone="git clone"
    alias ga="git add"
    alias gs="git status"
    alias gc="git commit"
    alias gps="git push"
    alias gpl="git pull"
    alias gco="git checkout "
    alias gr="git reset"
    alias gss="git stash save"
    alias gsp="git stash pop"
    alias gsd="git stash drop"
    alias gsa="git stash apply"
    alias gsl="git stash list"
    alias gsw="git stash show"
fi

################################################################################
#                         Package management shortcuts                         #
################################################################################
# TODO Make a small function to install system basics

if hash docker 2>/dev/null; then
    if [[ $EUID -ne 0 ]]; then
        alias docker="sudo docker"
        alias docker-compose="sudo docker-compose"
    fi

    alias dkpa="docker ps -a"
fi

# Yeah I'm too lazy to remember each command in every distro soooooo
# I added this alias
# TODO add other distros commands I've used, like Solus
pkg=""
if hash yaourt 2>/dev/null || hash pacman 2>/dev/null; then
    # 'Install' package maybe in the PATH

    if hash yaourt 2>/dev/null; then
        pkg="yaourt"
    elif hash pacman 2>/dev/null; then
        # Yeah Arch from scratch may not have yaourt
        pkg="pacman"
    fi

    alias searchpkg="${pkg} -Ss"

    alias getpkg="${pkg} -S"
    alias getpkgn="${pkg} -S --noconfirm"

    alias update="${pkg} -Syyu --aur"
    alias updaten="${pkg} -Syyu --aur --noconfirm"

    alias rmpkg="${pkg} -Rns"

    if [[ $EUID -ne 0 ]] && hash pacman 2>/dev/null; then
        unalias getpkg && alias getpkg="sudo ${pkg} -S"
        unalias getpkgn && alias getpkgn="sudo ${pkg} -S --noconfirm"

        unalias update && alias update="sudo ${pkg} -Syyu --aur"
        unalias updaten && alias updaten="sudo ${pkg} -Syyu --aur --noconfirm"

        unalias rmpkg && alias rmpkg="sudo ${pkg} -Rns"
    fi

elif hash apt-get 2>/dev/null || hash apt 2>/dev/null; then

    if hash apt 2>/dev/null; then
        pkg="apt"
    elif hash apt-get 2>/dev/null; then
        pkg="apt-get"
    fi

    # alias searchpkg="${apt} install"
    if [[ $EUID -ne 0 ]]; then
        alias getpkgn="sudo ${pkg} install -y"

        alias update="sudo ${pkg} update && sudo ${pkg} upgrade"
        alias updaten="sudo ${pkg} update && sudo ${pkg} upgrade -y"

        alias rmpkg="sudo ${pkg} remove"
    else
        alias getpkg="${pkg} install"
        alias getpkgn="${pkg} install -y"

        alias update="${pkg} update && ${pkg} upgrade"

        alias rmpkg="${pkg} remove"
    fi

elif hash dnf 2>/dev/null || hash yum 2>/dev/null ; then

    if hash dnf 2>/dev/null; then
        pkg="dnf"
    elif hash yum 2>/dev/null; then
        pkg="yum"
    fi

    alias searchpkg="${pkg} search"

    if [[ $EUID -ne 0 ]]; then
        alias getpkg="sudo ${pkg} install"
        alias getpkgn="sudo ${pkg} -y install"

        alias update="sudo ${pkg} update"

        alias rmpkg="sudo ${pkg} remove"
    else
        alias getpkg="${pkg} install"
        alias getpkgn="${pkg} -y install"

        alias update="${pkg} update"

        alias rmpkg="${pkg} remove"
    fi
fi
unset pkg


################################################################################
#               Functions to move around dirs and other simple stuff           #
################################################################################

# # FIXME
# function __create_alias() {
#     local test_path=""
#     local test_cmd=0
#
#     for key in "$@"; do
#         case "$key" in
#             -h|--help)
#
#                 echo ""
#                 echo "  This function create attempts to create an alias"
#                 echo "  receives a name, alias and optionally a path"
#                 echo ""
#                 echo "  This function is not intended to be directly in the prompt"
#                 echo "  instead it is expected to help automatize alias creation for"
#                 echo "  different host, and help portability"
#                 echo ""
#                 echo "  Usage:"
#                 echo "      $ __create_alias NAME ALIAS [OPTIONAL]"
#                 echo "          Ex."
#                 echo "          $ __create_alias gohome 'cd ~/' -p /home/$USER"
#                 echo "          $ __create_alias gohome 'cd ~/' -p /home/$USER -p /sbin/"
#                 echo "          $ __create_alias fuck ' echo \"y u mad?\" ' -c"
#                 echo ""
#                 echo "      Optional Flags"
#                 echo "          -c, --command"
#                 echo "              Check if the given name already exists in the current"
#                 echo "              shell"
#                 echo ""
#                 echo "          -p PATH, --path PATH"
#                 echo "              Check whether or not the given path exists"
#                 echo ""
#                 echo "          -h, --help"
#                 echo "              Display help and exit. If you are seeing this,"
#                 echo "              that means that you already know it (nice)"
#                 ;;
#         esac
#     done
#
#     if [[ $# -le 1 ]]; then
#         echo "  ---- [X] Error This function receives at least 2 args, NAME and ALIAS" 1>&2
#         return 1
#     fi
#
#     local name="$1"
#     shift
#     local new_alias="$1"
#     shift
#
#     while [[ $# -gt 0 ]]; do
#         local key="$1"
#         case "$key" in
#             -p|--path)
#                 local test_path="$2"
#                 shift # Shift flag
#                 shift # Shift path
#
#                 if [[ ! -d "$test_path" ]]; then
#                     echo "  ---- [X] Error The given path ( $test_path ) doesn't exist" 1>&2
#                     return 2
#                 fi
#                 ;;
#             -c|--command)
#                 local test_cmd=1
#                 shift # Shift flag
#                 ;;
#         esac
#     done
#
#     if [[ $test_cmd -eq 1 ]]; then
#         if hash $name 2>/dev/null; then
#             echo "  ---- [X] Error The given command already exists ( $name )" 1>&2
#             return 2
#         fi
#     fi
#
#     alias $name="$new_alias"
#     return 0
# }

# TODO: Move this crap to ${SHELL}.logout
function killssh() {
    if hash pgrep 2>/dev/null; then
        if [[ ! -z $(pgrep -u $USER ssh-agent) ]]; then
            kill -7 $(pgrep -u $USER ssh-agent)
        fi
    fi
    return 0
}

function ssha() {
    eval "$(ssh-agent)"
    ssh-add ~/.ssh/id_rsa
    return 0
}

# Simple map of "q" to deactivate virtualenv or exit terminal session
function q() {
    if hash deactivate 2> /dev/null; then
        deactivate
    else
        killssh
        exit
    fi
}

function venv() {
    local _git=0
    local _name="env"
    local _top="."

    while [[ $# -gt 0 ]]; do
        local key="$1"
        case "$key" in
            -h|--help)
                echo ""
                echo "  Source given virtualevn"
                echo ""
                echo "  Usage:"
                echo "      venv [OPTIONAL]"
                echo "          Ex."
                echo "          $ venv -g"
                echo "          $ venv -g django"
                echo "          $ venv ~/django"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit."
                echo ""
                return 0
                ;;
            -g|--git)
                local _git=1
                ;;
            *)
                local _name="$2"
                shift
                ;;
        esac
        shift
    done

    if [[ $_git -eq 1 ]]; then
        if ! git rev-parse --show-toplevel 1> /dev/null; then
            echo "[X]     ---- Error!!!   Git repo error"
            return 1
        fi

        _top="$(git rev-parse --show-toplevel)"
        _top="$_top/.git"

        _name="$_top/$_name"
    fi

    if [[ ! -f "$_name/bin/activate" ]]; then
        echo "[X]     ---- Error!!!  Missing activate file, $_name/bin/activate" 1>&2
        return 1
    fi

    # shellcheck disable=SC1090
    source "$_name/bin/activate"

    return 0
}

function bk() {
    for key in "$@"; do
        case "$key" in
            -h|--help)

                echo ""
                echo "  Function to go back any number of dirs"
                echo ""
                echo "  Usage:"
                echo "      $ bk [Number of nodes to move back] [OPTIONAL]"
                echo "          Ex."
                echo "          $ bk 2 # = cd ../../"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit. If you are seeing this,"
                echo "              that means that you already know it (nice)"
                echo ""

                return 0
                ;;
        esac
    done

    if [[ ! -z "$1" ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
        local parent="./"
        for (( i = 0; i < $1; i++ )); do
            local parent="${parent}../"
        done
        cd "$parent" || return 1
    elif [[ -z "$1" ]]; then
        cd ..
    else
        echo "  ---- [X] Error Unexpected arg $1, please provide a number" 1>&2
        return 1
    fi

    return 0
}

function mkcd() {
    for key in "$@"; do
        case "$key" in
            -h|--help)

                echo ""
                echo "  Create a dir an move to it"
                echo ""
                echo "  Usage:"
                echo "      mkcd NEW_DIR [OPTIONAL]"
                echo "          Ex."
                echo "          $ mkcd new_foo"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit."
                echo ""

                return 0
                ;;
        esac
    done

    if [[ ! -z "$1" ]]; then
        mkdir -p "$1"
        cd "$1" || return 1
        return 0
    fi
    return 1
}

function llg() {
    if [[ ! -z "$1" ]]; then
        ls -lhA | grep "$@"
    fi
}

function rl() {
    rm -f "$@" ./*.log
    return 0
}

# Init original path with HOME dir
ORIGINAL_PATH="$(pwd)"

# Move to the realpath version of the curren working dir
function crp() {
    # Save the current path
    ORIGINAL_PATH="$(pwd)"
    cd "$(grp)" || return 1
}

# Go back to the last sym path or $HOME
function gobk() {
    cd "$ORIGINAL_PATH" || return 1
}

# Go relative path
# alias grp="gobk"

# Check what's in the trash can
function cdt() {
    if [[ -d /tmp/.trash ]]; then
        pushd /tmp/.trash 1> /dev/null || exit 1
    fi
    return 0
}

# TODO: Make full pattern substitution to change any node of the string
function replace_base() {
    local cwd
    local new_cwd
    for key in "$@"; do
        case "$key" in
            -h|--help)

                echo ""
                echo "  Function to look for the nearest ancestor with the full given path"
                echo ""
                echo "  Usage:"
                echo "      $ replace_base DIR [OPTIONAL]"
                echo "          Ex."
                echo "          /home/$USER/foo/dummy $ replace_base bar"
                echo "          /home/$USER/bar/dummy $"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit. If you are seeing this,"
                echo "              that means that you already know it (nice)"
                echo ""

                return 0
                ;;
        esac
    done

    if [[ -z "$1" ]]; then
        echo "  ---- [X] Error Unexpected arg $1, please provide a number" 1>&2
        return 1
    fi

    new_cwd="$1"
    cwd="$(pwd)"

    local new_path=""

    local array_list
    # shellcheck disable=SC2207
    array_list=($( pwd | tr '/' "\n"))

    for i in "${array_list[@]}"; do
        new_path="${cwd/$i/$new_cwd}"
        if [[ -d "$new_path" ]] && [[ "$new_path" != "$(pwd)" ]]; then
            if ! pushd "$new_path" 1> /dev/null; then
                return 1
            fi
            return 0
        fi
        new_path=""
    done

    echo "  ---- [X] Error $new_cwd is not a parent relative dir" 1>&2
    return 1
}

alias rb="replace_base"

function change_base() {
    local cwd
    local new_cwd
    for key in "$@"; do
        case "$key" in
            -h|--help)

                echo ""
                echo "  Function to look for the nearest ancestor of given dir"
                echo ""
                echo "  Usage:"
                echo "      $ change_base DIR [OPTIONAL]"
                echo "          Ex."
                echo "          /home/$USER/foo $ change_base bar"
                echo "          /home/$USER/bar $"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit. If you are seeing this,"
                echo "              that means that you already know it (nice)"
                echo ""

                return 0
                ;;
        esac
    done

    if [[ -z "$1" ]]; then
        echo "  ---- [X] Error Unexpected arg $1, please provide a number" 1>&2
        return 1
    fi

    cwd="$(pwd)"
    new_cwd="$1"

    local new_path=""

    while [[ $cwd != "" ]]; do
        local cwd="${cwd%/*}"
        local new_path="$cwd/$new_cwd"

        if [[ -d  "$new_path" ]] && [[ "$new_path" != "$(pwd)" ]]; then
            if ! pushd "$new_path" 1> /dev/null; then
                return 1
            fi
            return 0
        fi
    done

    echo "  ---- [X] Error $1 is not a parent relative dir" 1>&2
    return 1
}

alias cb="change_base"


if hash emacs 2>/dev/null; then
    function cmacs() {
        emacsclient -nw "$@"
    }

    function gmacs() {
        emacsclient -c "$@" &
    }

    function dmacs() {
        emacs --daemon &
    }

    function kmacs() {
        emacsclient -e "(kill-emacs)"
    }
fi
