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

function help_user() {
    echo ""
    echo "  Checks whether a website is down for you, or everybody"
    echo ""
    echo "  Usage:"
    echo "      $NAME URL"
    echo "          Ex."
    echo "          $ $NAME google.com"
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

if [[ ! -z "$1" ]]; then
    curl -s -L --max-redirs 1 "http://www.downforeveryoneorjustme.com/$1" | grep -oE "It's just you.|It's not just you!"
fi

exit 0
