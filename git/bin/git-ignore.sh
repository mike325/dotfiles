#!/usr/bin/env bash

#   Author: Mike 8a
#   Description: Install all my basic configs and scripts
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

function help_user() {
    echo ""
    echo "  Simple installer of this dotfiles, by default install (link) all settings and configurations"
    echo "  if any flag ins given, the script will install just want is being told to do."
    echo "      By default command (if none flag is given): $_NAME -s -a -e -v -n -b -g"
    echo ""
    echo "  Usage:"
    echo "      $_NAME [OPTIONAL]"
    echo ""
    echo "      Optional Flags"
    echo ""
    echo "          -h, --help"
    echo "              Display help, if you are seeing this, that means that you already know it (nice)"
    echo ""
}

function warn_msg() {
    WARN_MESSAGE="$1"
    printf "[!]     ---- Warning!!! $WARN_MESSAGE \n"
}

function error_msg() {
    ERROR_MESSAGE="$1"
    printf "[X]     ---- Error!!!   %s \n" "$ERROR_MESSAGE" 1>&2
}

function status_msg() {
    STATUS_MESSAGGE="$1"
    printf "[*]     ---- $STATUS_MESSAGGE \n"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
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

if hash curl 2> /dev/null; then
    _RESULT=$(curl -L "https://www.gitignore.io/api/$@" 2>/dev/null)
elif hash wget; then
    _RESULT=$(wget -O- "${curl_args[@]}" http://gitignore.io/api/"${gi_args[*]}")
else
    :
fi

exit 0
