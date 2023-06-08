#!/usr/bin/env bash

################################################################################
#   Some useful functions I took from https://github.com/Bash-it/bash-it/      #
#   I like to have them even tho I don't activate the plugins or when I'm in   #
#   zsh                                                                        #
################################################################################

#   Description: Checks whether a website is down for you, or everybody
#
#   Usage:
#       $ down4me http://www.google.com
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

NAME="$0"
NAME="${NAME##*/}"
_PING=0

function help_user() {
    cat <<EOF

Description:
    Checks whether a website is down for you, or everybody

Usage:
    $NAME URL
        Ex.
        $ $NAME google.com

    Optional Flags
        -h, --help  Display this help message
EOF
}

for key in "$@"; do
    case "$key" in
        -p | --ping)
            _PING=1
            ;;
        -h | --help)
            help_user
            exit 0
            ;;
    esac
done

if [[ $_PING -eq 1 ]]; then
    if ! ping -c 5 www.downforeveryoneorjustme.com >/dev/null; then
        echo 'You may not have network'
    else
        echo 'Great!! it seems you have external connectivity'
    fi
elif [[ -n $1 ]]; then
    curl -Ls --max-redirs 1 "http://www.downforeveryoneorjustme.com/$1" | grep -oE "It's just you.|It's not just you!"
fi

exit 0
