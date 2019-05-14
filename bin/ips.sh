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
    cat << EOF

Description:
    Display all ip addresses for this host

Usage:
    $NAME [OPTIONAL]
        Ex.
        $ $NAME

    Optional Flags
        -a, --all
            Display all IPs, local and real

        -l, --local
            Display local IPs, this option is enable by default
            This option is enable by default
            ----    Turn off real IP

        -r, --real
            Display the real IP (as seen from the internet)
            ----    Turn off local IP

        -h, --help
            Display help and exit. If you are seeing this, that means that you already know it (nice)

EOF
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
    res="$(curl -s ifconfig.me)"
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
        *)
            error_msg "Unknown argument $key"
            help_user
            exit 1
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
