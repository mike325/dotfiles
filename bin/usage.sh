#!/usr/bin/env bash

################################################################################
#   Some useful functions I took from https://github.com/Bash-it/bash-it/      #
#   I like to have them even tho I don't activate the plugins or when I'm in   #
#   zsh                                                                        #
################################################################################

#   Description: Disk usage per directory in Linux
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
#            .`    github.com/mike325/dotfiles   /

_NAME="$0"
_NAME="${_NAME##*/}"

SORT=0
declare -a ARGS

function help_user() {
    cat << EOF
Description:
    Disk usage per directory/file in Linux

Usage:
    $_NAME [PATH/FILE] [OPTIONAL]
        Ex.
        $ $_NAME
        $ $_NAME ./folder

    Optional Flags
        -s, --sort
            Sort the results

        -h, --help
            Display help and exit. If you are seeing this, that means that you already know it (nice)

EOF
}

i=0
for key in "$@"; do
    case "$key" in
        -h|--help)
            help_user
            exit 0
            ;;
        -s|--sort)
            SORT=1
            ;;
        *)
            ARGS[i]="$key"
            i=$i+1
            ;;
    esac
done

if [[ $SORT -eq 1 ]]; then
    du -h --max-depth=1 "${ARGS[@]}" | sort -h
else
    du -h --max-depth=1 "${ARGS[@]}"
fi

exit 0
