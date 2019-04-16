#!/usr/bin/env bash

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

_VERBOSE=0

_NAME="$0"
_NAME="${_NAME##*/}"

function help_user() {
    echo ""
    echo "  Description"
    echo ""
    echo "  Usage:"
    echo "      $_NAME"
    echo ""
    echo "      Optional Flags"
    echo ""
    echo "          -v, --verbose"
    echo "              Enable debug messages"
    echo ""
    echo "          -h, --help"
    echo "              Display help, if you are seeing this, that means that you already know it (nice)"
    echo ""
}

function warn_msg() {
    local warn_message="$1"
    printf "[!]     ---- Warning!!! %s \n" "$warn_message"
}

function error_msg() {
    local error_message="$1"
    printf "[X]     ---- Error!!!   %s \n" "$error_message" 1>&2
}

function status_msg() {
    local status_message="$1"
    printf "[*]     ---- %s \n" "$status_message"
}

function verbose_msg() {
    if [[ $_VERBOSE -eq 1 ]]; then
        local debug_message="$1"
        printf "[+]     ---- Debug!!!   %s \n" "$debug_message"
    fi
}

fe() {
    local files
    IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

if hash fzf 2>/dev/null; then
    fe "$@"
else
    error_msg "FZF is not install"
    exit 1
fi

exit 0
