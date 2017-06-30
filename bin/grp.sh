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
    echo ""
    echo "  Get the realpath of the given dir"
    echo "  This script tries to use 'realpath', if it's available, you could use"
    echo "  any possible flag; otherwise , if realpath is not available, 'pwd' will be use"
    echo ""
    echo "  Usage:"
    echo "      $NAME [PATH] [OPTIONAL]"
    echo "          Ex."
    echo "          $ $NAME ./foo_link/file"
    echo "          $ $NAME"
    echo ""
    echo "      Optional Flags"
    echo "          -h, --help"
    echo "              Display help and exit. If you are seeing this, that means that you already know it (nice)"
    echo ""
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
else
    # TODO Optimize code for file management
    if [[ ! -z "$1" ]]; then
        FULL_PATH="$1"
        ROOT_PATH="${FULL_PATH%/*}"
        FILE_PATH="${FULL_PATH##*/}"

        pushd . > /dev/null

        if [[ -f "$FULL_PATH" ]]; then
            pushd "$ROOT_PATH" &> /dev/null

            # I haven't think a better way to check if the given path was
            # push into the stack, that's why I can't print the path a
            # then pop it
            if [[ $? -eq 0 ]]; then
                echo "$(pwd -P)/$FILE_PATH"
                popd > /dev/null
            else
                echo "$(pwd -P)/$FILE_PATH"
            fi

        elif [[ -d "$FULL_PATH" ]]; then
            ROOT_PATH="$1"

            pushd "$ROOT_PATH" > /dev/null

            echo "$(pwd -P)"

            popd > /dev/null
        else
            echo "    ---- [X] Error 404 the given path doesn't exist"
        fi

        # Retrun to the original dir
        popd > /dev/null

    else
        pwd -P
    fi
fi
