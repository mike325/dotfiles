#!/usr/bin/env bash

################################################################################
#   Some useful functions I took from https://github.com/Bash-it/bash-it/      #
#   I like to have them even tho I don't activate the plugins or when I'm in   #
#   zsh                                                                        #
################################################################################

#   Description: Move files to hidden folder in tmp, that gets cleared on each reboot
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
    cat << EOF

Description:
    Move files/folders to hidden location in tmp, that gets cleared on each reboot

Usage:
    $NAME PATH/FILE [OPTIONAL]
        Ex.
        $ $NAME ./folder
        $ $NAME ./foo ./bar ~/tmp

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

mkdir -p /tmp/.trash

for i in "$@"; do
    if [[ -d "$i" ]] || [[ -f "$i" ]]; then
        mv --backup=numbered "$i" /tmp/.trash;
    else
        error_msg "$i doesn't exists"
    fi
done

exit 0
