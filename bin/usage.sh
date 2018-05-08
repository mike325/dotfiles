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
    echo ""
    echo "  Disk usage per directory/file in Linux"
    echo ""
    echo "  Usage:"
    echo "      $_NAME [PATH/FILE] [OPTIONAL]"
    echo "          Ex."
    echo "          $ $_NAME ./folder"
    echo ""
    echo "      Optional Flags"
    echo "          -s, --sort"
    echo "              Sort the results"
    echo ""
    echo "          -h, --help"
    echo "              Display help and exit. If you are seeing this, that means that you already know it (nice)"
    echo ""
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
