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
    cat <<EOF

Description:
    Move a original dir to the 'trash' and move/rename the first dir.

Usage:
    $NAME FILE/DIR FILE/DIR [OPTIONAL]
        Ex.
        $ $NAME ~/stuff ./mistake    # will 'remove' ./mistake  and move/rename ~/stuff to ./mistake
        $ $NAME file_stuff new_stuff # will 'remove' new_stuff and move/rename file_stuff to new_stuff

Optional Flags
    -h, --help  Display this help message
EOF
}

for key in "$@"; do
    case "$key" in
        -h | --help)
            help_user
            exit 0
            ;;
    esac
done

if [[ -n $1 ]] && [[ -n $2 ]]; then
    mkdir -p /tmp/.trash
    mv --backup=numbered "$2" /tmp/.trash
    mv "$1" "$2"
fi

exit 0
