#!/usr/bin/env bash

################################################################################
#   Some useful functions I took from https://github.com/Bash-it/bash-it/      #
#   I like to have them even tho I don't activate the plugins or when I'm in   #
#   zsh                                                                        #
################################################################################

#   Description: Display all ip addresses for this host
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
LOCAL=1
ALL=0
REAL=0

function help_user() {
    echo ""
    echo "  Display all ip addresses for this host"
    echo ""
    echo "  Usage:"
    echo "      $NAME [OPTIONAL]"
    echo "          Ex."
    echo "          $ $NAME"
    echo ""
    echo "      Optional Flags"
    echo "          -a, --all"
    echo "              Display all IPs, local and real"
    echo ""
    echo "          -l, --local"
    echo "              Display local IPs, this option is enable by default"
    echo "              This option is enable by default"
    echo "              ----    Turn off real IP"
    echo ""
    echo "          -r, --real"
    echo "              Display the real IP (as seen from the internet)"
    echo "              ----    Turn off local IP"
    echo ""
    echo "          -h, --help"
    echo "              Display help and exit. If you are seeing this, that means that you already know it (nice)"
    echo ""
}

function error_msg() {
    ERROR_MESSAGE="$1"
    printf "[X]     ---- Error!!!   %s \n" "$ERROR_MESSAGE" 1>&2
}


function local_ips() {
    echo ""
    echo -e "Local IPs"
    if command -v ifconfig &>/dev/null; then
        ifconfig | awk '/inet /{ print $2 }'
    elif command -v ip &>/dev/null; then
        ip addr | grep -oP 'inet \K[\d.]+'
    else
        error_msg "You don't have ifconfig or ip command installed!"
        return 1
    fi
    return 0
}

function real_ip() {
    echo ""
    local res
    res=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
    echo -e "Public IP"
    echo -e "$res"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -a|--all)
            ALL=1
            ;;
        -r|--real)
            REAL=1
            LOCAL=0
            ;;
        -l|--local)
            REAL=0
            LOCAL=1
            ;;
        -h|--help)
            help_user
            exit 0
            ;;
    esac
    shift
done

if [[ $ALL -eq 1 ]]; then
    local_ips
    real_ip
else
    [[ $LOCAL -eq 1 ]] && local_ips
    [[ $REAL -eq 1 ]] && real_ip
fi

exit 0
