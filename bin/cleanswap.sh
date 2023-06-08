#!/usr/bin/env bash

#   Author: Mike 8a
#   Description: Clean (Neo)vim swap files
#
#                              -`
#              ...            .o+`
#           .+++s+   .h`.    `ooo/
#          `+++%++  .h+++   `+oooo:
#          +++o+++ .hhs++. `+oooooo:
#          +s%%so%.hohhoo'  'oooooo+:
#          `+ooohs+h+sh++`/:  ++oooo+:
#           hh+o+hoso+h+`/++++.+++++++:
#            `+h+++h.+ `/++++++++++++++:
#                     `/+++ooooooooooooo/`
#                    ./ooosssso++osssssso+`
#                   .oossssso-````/osssss::`
#                  -osssssso.      :ssss``to.
#                 :osssssss/  Mike  osssl   +
#                /ossssssss/   8a   +sssslb
#              `/ossssso+/:-        -:/+ossss'.-
#             `+sso+:-`                 `.-/+oso:
#            `++:.                           `-/+/
#            .`                                 `/

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"
WARN_COUNT=0
ERR_COUNT=0
NOCOLOR=0
NOLOG=0

SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH%/*}"

# colors
# shellcheck disable=SC2034
black="\033[0;30m"
# shellcheck disable=SC2034
red="\033[0;31m"
# shellcheck disable=SC2034
green="\033[0;32m"
# shellcheck disable=SC2034
yellow="\033[0;33m"
# shellcheck disable=SC2034
blue="\033[0;34m"
# shellcheck disable=SC2034
purple="\033[0;35m"
# shellcheck disable=SC2034
cyan="\033[0;36m"
# shellcheck disable=SC2034
white="\033[0;37;1m"
# shellcheck disable=SC2034
orange="\033[0;91m"
# shellcheck disable=SC2034
normal="\033[0m"
# shellcheck disable=SC2034
reset_color="\033[39m"

if hash realpath 2>/dev/null; then
    SCRIPT_PATH=$(realpath "$SCRIPT_PATH")
else
    pushd "$SCRIPT_PATH" 1>/dev/null  || exit 1
    SCRIPT_PATH="$(pwd -P)"
    popd 1>/dev/null  || exit 1
fi

if ! hash is_windows 2>/dev/null; then
    function is_windows() {
        if [[ $SHELL_PLATFORM =~ (msys|cygwin|windows) ]]; then
            return 0
        fi
        return 1
    }
fi

# _DEFAULT_SHELL="${SHELL##*/}"
if [[ -n $ZSH_NAME ]]; then
    CURRENT_SHELL="zsh"
elif [[ -n $BASH ]]; then
    CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    if [[ -z $CURRENT_SHELL ]]; then
        CURRENT_SHELL="${SHELL##*/}"
    fi
fi

function help_user() {
    cat <<EOF

Description:
    Clean (Neo)vim swap files

Usage:
    $NAME [OPTIONAL]

    Optional Flags
        -h, --help      Display this help message
EOF
}

function __parse_args() {
    local arg="$1"
    local name="$2"

    local pattern="^--${name}[=][a-zA-Z0-9./]+$"
    if [[ -n $3 ]]; then
        local pattern="^--${name}[=]$3$"
    fi

    if [[ $arg =~ $pattern ]]; then
        local left_side="${arg#*=}"
        echo "$left_side"
    else
        echo "$arg"
    fi
}

function warn_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$msg"
    else
        printf "[!] Warning:\t %s\n" "$msg"
    fi
    WARN_COUNT=$((WARN_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

function error_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$msg" 1>&2
    else
        printf "[X] Error:\t %s\n" "$msg" 1>&2
    fi
    ERR_COUNT=$((ERR_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[X] Error:\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

function status_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s\n" "$msg"
    else
        printf "[*] Info:\t %s\n" "$msg"
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

function verbose_msg() {
    local msg="$1"
    if [[ $VERBOSE -eq 1 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$msg"
        else
            printf "[+] Debug:\t %s\n" "$msg"
        fi
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -h | --help)
            help_user
            exit 0
            ;;
        *)
            error_msg "Unknown argument $key"
            help_user
            exit 1
            ;;
    esac
    shift
done

status_msg "Cleaning swap files"

if is_windows; then
    [[ -d "$HOME/AppData/Local/nvim/data/swap/" ]] && rm -rf ~/AppData/Local/nvim/data/swap/*
    [[ -d "$HOME/AppData/Local/nvim-data/swap/" ]] && rm -rf ~/AppData/Local/nvim-data/swap/*
    [[ -d "$HOME/vimfiles/data/swap/" ]] && rm -rf ~/vimfiles/data/swap/*
else
    [[ -d "$HOME/.config/nvim/data/swap/" ]] && rm -rf ~/.config/nvim/data/swap/*
    [[ -d "$HOME/.local/share/nvim/swap/" ]] && rm -rf ~/.local/share/nvim/swap/*
fi

[[ -d "$HOME/.vim/data/swap/" ]] && rm -rf ~/.vim/data/swap/*

exit 0
