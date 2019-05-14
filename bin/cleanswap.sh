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

_NAME="$0"
_NAME="${_NAME##*/}"

_SCRIPT_PATH="$0"
_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

if hash realpath 2>/dev/null; then
    _SCRIPT_PATH=$(realpath "$_SCRIPT_PATH")
else
    pushd "$_SCRIPT_PATH" 1> /dev/null || exit 1
    _SCRIPT_PATH="$(pwd -P)"
    popd 1> /dev/null || exit 1
fi

function is_windows() {
    if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then
        return 0
    fi
    return 1
}

# _DEFAULT_SHELL="${SHELL##*/}"
_CURRENT_SHELL="bash"

# shellcheck disable=SC2009,SC2046
_CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
_CURRENT_SHELL="${_CURRENT_SHELL##*/}"

if ! is_windows; then
    # Hack when using sudo
    # TODO: Must fix this
    if [[ $_CURRENT_SHELL == "sudo" ]] || [[ $_CURRENT_SHELL == "su" ]]; then
        _CURRENT_SHELL="$(ps | head -4 | tail -n 1 | awk '{ print $4 }')"
    fi
fi

function help_user() {
    cat << EOF

Description:
    Clean (Neo)vim swap files

Usage:
    $_NAME [OPTIONAL]

    Optional Flags

        -h, --help
            Display help, if you are seeing this, that means that you already know it (nice)

EOF
}

function __parse_args() {
    local arg="$1"
    local name="$2"

    local pattern="^--$name[=][a-zA-Z0-9./]+$"
    if [[ ! -z "$3" ]]; then
        local pattern="^--$name[=]$3$"
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
    [[ -d "$HOME/AppData/Local/nvim/.resources/swap/" ]] && rm -rf ~/AppData/Local/nvim/.resources/swap/*
    [[ -d "$HOME/vimfiles/.resources/swap/" ]] && rm -rf ~/vimfiles/.resources/swap/*
else
    [[ -d "$HOME/.config/nvim/.resources/swap/" ]] && rm -rf ~/.config/nvim/.resources/swap/*
fi

[[ -d "$HOME/.vim/.resources/swap/" ]] && rm -rf ~/.vim/.resources/swap/*

exit 0
