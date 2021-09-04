#!/usr/bin/env bash

#   Author: Mike 8a
#   Description: Get the realpath of the given dir
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
#            .`   github.com/mike325/dotfiles   `/

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"
WARN_COUNT=0
ERR_COUNT=0
NOCOLOR=0
NOLOG=0

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

function help_user() {
    cat <<EOF

Description:
    Tries to get the real path of the given dir/file
    The following tools are used in the given order:
        1) realpath
        2) readlink -f
        3) pwd

    If realpath is available, you can give any argument directly to it.

Usage:
    $NAME [PATH] [OPTIONAL]
        Ex.
        $ $NAME ./foo_link/file
        $ $NAME

    Optional Flags
        -h, --help
            Display help and exit. If you are seeing this, that means that you already know it (nice)

EOF
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

for key in "$@"; do
    case "$key" in
        -h | --help)
            help_user
            exit 0
            ;;
    esac
done

if hash realpath 2>/dev/null; then
    if [[ -n $1 ]]; then
        realpath "$@"
    else
        realpath "."
    fi
elif hash readlink 2>/dev/null; then
    if [[ -n $1 ]]; then
        readlink -f "$@"
    else
        readlink -f "."
    fi
else
    # TODO Optimize code for file management
    if [[ -n $1 ]]; then
        FULL_PATH="$1"
        ROOT_PATH="${FULL_PATH%/*}"
        FILE_PATH="${FULL_PATH##*/}"

        pushd . 1>/dev/null  || exit 1

        if [[ -f $FULL_PATH ]]; then

            # I haven't think a better way to check if the given path was
            # push into the stack, that's why I can't print the path a
            # then pop it
            if pushd "$ROOT_PATH" 2>/dev/null; then
                echo "$(pwd -P)/$FILE_PATH"
                popd 1>/dev/null  || exit 1
            else
                echo "$(pwd -P)/$FILE_PATH"
            fi

        elif [[ -d $FULL_PATH ]]; then
            ROOT_PATH="$1"

            pushd "$ROOT_PATH" 1>/dev/null  || exit 1

            pwd -P

            popd 1>/dev/null  || exit 1
        else
            error_msg "The given path doesn't exist"
        fi

        # Retrun to the original dir
        popd 1>/dev/null  || exit 1

    else
        pwd -P
    fi
fi

exit 0
