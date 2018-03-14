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

if hash nvim 2>/dev/null; then
    if [[ $(uname --all) =~ MINGW ]]; then
        alias nvim="nvim-qt &"
        alias cdvi="cd ~/.vim"
        alias cdvim="cd ~/AppData/Local/nvim/"
        export MANPAGER="env MAN_PN=1 vim -M +MANPAGER -"
        export EDITOR="vim"

        alias vi="vim --cmd \"let g:minimal=0\""
        alias viu="vim -u NONE"
    else
        alias cdvi="cd ~/.vim"
        alias cdvim="cd ~/.config/nvim"
        export EDITOR="nvim"
        export MANPAGER="nvim -c 'set ft=man' -"

        alias vi="nvim --cmd \"let g:minimal=0\""
        alias viu="nvim -u NONE"
    fi
    # Fucking typos
    alias nvi="nvim"
    alias vnim="nvim"
else
    alias cdvim="cd ~/.vim"
    export EDITOR="vim"
    export MANPAGER="env MAN_PN=1 vim -M +MANPAGER -"

    alias vi="vim --cmd \"let g:minimal=0\""
    alias viu="vim -u NONE"
fi

################################################################################
#                          Fix my common typos                                 #
################################################################################

alias gti="git"
alias got="git"
alias gut="git"
alias gi="git"

alias bim="vim"
alias cim="vim"
alias im="vim"

################################################################################
#                        Some useful shortcuts                                 #
################################################################################

# Check all user process
alias psu='ps -u $USER'

# alias q="exit"
alias cl="clear"
if [[ $EUID -ne 0 ]]; then
    alias turnoff="sudo poweroff"
else
    alias turnoff="poweroff"
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

    # Yep tons of fucks
    alias guck='fuck'
    alias fukc='fuck'
    alias gukc='fuck'
    alias fuvk='fuck'
else
    :
    # alias fuck='sudo $(history -p \!\!)'
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
if hash yaourt 2>/dev/null; then
    # 'Install' package maybe in the PATH
    alias getpkg="yaourt -S"
    alias getpkgn="yaourt -S --noconfirm"

    alias searchpkg="yaourt -Ss"

    alias update="yaourt -Syyu --aur"

    alias update="yaourt -Syyu --aur"
    alias updaten="yaourt -Syyu --aur --noconfirm"

    alias rmpkg="yaourt -Rns"

    # Yeah Arch from scratch may not have yaourt
elif hash pacman 2>/dev/null; then
    alias searchpkg="pacman -Ss"

    if [[ $EUID -ne 0 ]]; then
        alias getpkg="sudo pacman -S"
        alias getpkgn="sudo pacman -S --noconfirm"

        alias update="sudo pacman -Syyu"
        alias updaten="sudo pacman -Syyu --noconfirm"

        alias rmpkg="sudo pacman -Rns"
    else
        alias getpkg="pacman -S"
        alias getpkgn="pacman -S --noconfirm"

        alias update="pacman -Syyu"
        alias updaten="pacman -Syyu --noconfirm"

        alias rmpkg="pacman -Rns"
    fi

elif hash apt-get 2>/dev/null || hash apt 2>/dev/null; then
    alias searchpkg="apt search"

    if [[ $EUID -ne 0 ]]; then
        alias getpkg="sudo apt install"
        alias getpkgn="sudo apt install -y"

        alias update="sudo apt update && sudo apt upgrade"
        alias updaten="sudo apt update && sudo apt upgrade -y"

        alias rmpkg="sudo apt remove"
    else
        alias getpkg="apt install"
        alias getpkgn="apt install -y"

        alias update="apt update && apt upgrade"

        alias rmpkg="apt remove"
    fi

elif hash dnf 2>/dev/null; then
    alias searchpkg="dnf search"

    if [[ $EUID -ne 0 ]]; then
        alias getpkg="sudo dnf install"
        alias getpkgn="sudo dnf -y install"

        alias update="sudo dnf update"

        alias rmpkg="sudo dnf remove"
    else
        alias getpkg="dnf install"
        alias getpkgn="dnf -y install"

        alias update="dnf update"

        alias rmpkg="dnf remove"
    fi
fi


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
