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
LOG="${NAME%%.*}.log"
WARN_COUNT=0
ERR_COUNT=0
NOCOLOR=0
NOLOG=0

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


function warn_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$msg"
    else
        printf "[!] Warning:\t %s\n" "$msg"
    fi
    WARN_COUNT=$(( WARN_COUNT + 1 ))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$msg" >> "${LOG}"
    fi
    return 0
}

function error_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$msg" 1>&2
    else
        printf "[X] Error:\t %s\n" "$msg" 1>&2
    fi
    ERR_COUNT=$(( ERR_COUNT + 1 ))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[X] Error:\t %s\n" "$msg" >> "${LOG}"
    fi
    return 0
}

function status_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s\n" "$msg"
    else
        printf "[*] Info:\t %s\n" "$msg"
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$msg" >> "${LOG}"
    fi
    return 0
}

function verbose_msg() {
    local msg="$1"
    if [[ $VERBOSE -eq 1 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$msg"
        else
            printf "[+] Debug:\t %s\n" "$msg"
        fi
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$msg" >> "${LOG}"
    fi
    return 0
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
