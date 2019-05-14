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

function help_user() {
    cat << EOF

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

function error_msg() {
    ERROR_MESSAGE="$1"
    printf "[X]     ---- Error!!!   %s \n" "$ERROR_MESSAGE" 1>&2
}


for key in "$@"; do
    case "$key" in
        -h|--help)
            help_user
            exit 0
            ;;
    esac
done

if hash realpath 2>/dev/null; then
    if [[ ! -z "$1" ]]; then
        realpath "$@"
    else
        realpath "."
    fi
elif hash readlink 2>/dev/null; then
    if [[ ! -z "$1" ]]; then
        readlink -f "$@"
    else
        readlink -f "."
    fi
else
    # TODO Optimize code for file management
    if [[ ! -z "$1" ]]; then
        FULL_PATH="$1"
        ROOT_PATH="${FULL_PATH%/*}"
        FILE_PATH="${FULL_PATH##*/}"

        pushd . 1> /dev/null || exit 1

        if [[ -f "$FULL_PATH" ]]; then

            # I haven't think a better way to check if the given path was
            # push into the stack, that's why I can't print the path a
            # then pop it
            if pushd "$ROOT_PATH" 2> /dev/null; then
                echo "$(pwd -P)/$FILE_PATH"
                popd 1> /dev/null || exit 1
            else
                echo "$(pwd -P)/$FILE_PATH"
            fi

        elif [[ -d "$FULL_PATH" ]]; then
            ROOT_PATH="$1"

            pushd "$ROOT_PATH" 1> /dev/null || exit 1

            pwd -P

            popd 1> /dev/null || exit 1
        else
            error_msg "The given path doesn't exist"
        fi

        # Retrun to the original dir
        popd 1> /dev/null || exit 1

    else
        pwd -P
    fi
fi

exit 0
