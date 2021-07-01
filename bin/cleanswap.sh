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

SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH%/*}"

if hash realpath 2>/dev/null; then
    SCRIPT_PATH=$(realpath "$SCRIPT_PATH")
else
    pushd "$SCRIPT_PATH" 1> /dev/null || exit 1
    SCRIPT_PATH="$(pwd -P)"
    popd 1> /dev/null || exit 1
fi

if ! hash is_windows 2>/dev/null; then
    function is_windows() {
        if [[ $SHELL_PLATFORM =~ (msys|cygwin|windows) ]] ; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_wsl 2>/dev/null; then
    function is_wsl() {
        if [[ "$(uname -r)" =~ Microsoft ]] ; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_osx 2>/dev/null; then
    function is_osx() {
        if [[ $SHELL_PLATFORM == 'osx' ]]; then
            return 0
        fi
        return 1
    }
fi

# _DEFAULT_SHELL="${SHELL##*/}"
if [[ -n "$ZSH_NAME" ]]; then
    CURRENT_SHELL="zsh"
elif [[ -n "$BASH" ]]; then
    CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    if [[ -z "$CURRENT_SHELL" ]]; then
        CURRENT_SHELL="${SHELL##*/}"
    fi
fi

function help_user() {
    cat << EOF

Description:
    Clean (Neo)vim swap files

Usage:
    $NAME [OPTIONAL]

    Optional Flags

        -h, --help
            Display help, if you are seeing this, that means that you already know it (nice)

EOF
}

function __parse_args() {
    local arg="$1"
    local name="$2"

    local pattern="^--${name}[=][a-zA-Z0-9./]+$"
    if [[ -n "$3" ]]; then
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
    WARN_MESSAGE="$1"
    printf "[!]     ---- Warning!!! %s \n" "$WARN_MESSAGE"
}

function error_msg() {
    ERROR_MESSAGE="$1"
    printf "[X]     ---- Error!!!   %s \n" "$ERROR_MESSAGE" 1>&2
}

function status_msg() {
    STATUS_MESSAGGE="$1"
    printf "[*]     ---- %s \n" "$STATUS_MESSAGGE"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -h|--help)
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
