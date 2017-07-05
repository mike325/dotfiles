#!/usr/bin/env bash

#   Author: Mike 8a
#   Description: Move a original dir to the 'trash' and move/rename the first dir.
#
#                                     -`
#                     ...            .o+`
#                  .+++s+   .h`.    `ooo/
#                 `+++%++  .h+++   `+oooo:
#                 +++o+++ .hhs++. `+oooooo:
#                 +s%%so%.hohhoo'  'oooooo+:
#                 `+ooohs+h+sh++`/:  ++oooo+:
#                  hh+o+hoso+h+`/++++.+++++++:
#                   `+h+++h.+ `/++++++++++++++:
#                            `/+++ooooooooooooo/`
#                           ./ooosssso++osssssso+`
#                          .oossssso-````/osssss::`
#                         -osssssso.      :ssss``to.
#                        :osssssss/  Mike  osssl   +
#                       /ossssssss/   8a   +sssslb
#                     `/ossssso+/:-        -:/+ossss'.-
#                    `+sso+:-`                 `.-/+oso:
#                   `++:.                           `-/+/
#                   .`   github.com/mike325/dotfiles   `/

NAME="$0"
NAME="${NAME##*/}"

function help_user() {
    echo ""
    echo "  Move a original dir to the 'trash' and move/rename the first dir."
    echo ""
    echo "  Usage:"
    echo "      $NAME FILE/DIR FILE/DIR [OPTIONAL]"
    echo "          Ex."
    echo "          $ $NAME ~/stuff ./mistake    # will 'remove' ./mistake  and move/rename ~/stuff to ./mistake"
    echo "          $ $NAME file_stuff new_stuff # will 'remove' new_stuff and move/rename file_stuff to new_stuff"
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

if [[ ! -z "$1" ]] && [[ ! -z "$2" ]]; then
    mkdir -p /tmp/.trash
    mv --backup=numbered "$2" /tmp/.trash
    mv "$1" "$2"
fi