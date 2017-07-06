#!/usr/bin/env bash

#   Author: Mike 8a
#   Description: Small script to install bash-it or oh-my-zsh shell frameworks
#
#   Usage:
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

_DEFAULT_SHELL="${SHELL##*/}"
_CURRENT_SHELL="$(ps | grep `echo $$` | awk '{ print $4 }')"

function help_user() {
    echo ""
    echo "  Small script to install bash-it or oh-my-zsh shell frameworks"
    echo ""
    echo "  Usage:"
    echo "      $NAME [Number of nodes to move back] [OPTIONAL]"
    echo "          Ex."
    echo "          $ get_shell"
    echo ""
    echo "      Optional Flags"
    echo "          -h, --help"
    echo "              Display help and exit. If you are seeing this, that means that you already know it (nice)"
    echo ""
}

function warn_msg() {
    WARN_MESSAGE="$1"
    printf "[!] Warning!!! $WARN_MESSAGE \n"
}

function error_msg() {
    ERROR_MESSAGE="$1"
    printf "[X] Error!!!   $ERROR_MESSAGE \n"
}

function status_msg() {
    STATUS_MESSAGGE="$1"
    printf "[*]     $STATUS_MESSAGGE \n"
}

for key in "$@"; do
    case "$key" in
        -h|--help)
            help_user
            exit 0
            ;;
    esac
done

if [[ "$_CURRENT_SHELL" =~ "bash" ]]; then
    if [[ ! -d "$HOME/.bash_it" ]]; then
        status_msg "Cloning bash-it"
        git clone --recursive https://github.com/bash-it/bash-it "$HOME/.bash_it" 2>/dev/null
    else
        warn_msg "Bash-it is already install"
    fi
elif [[ "$_CURRENT_SHELL" =~ "zsh" ]]; then
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        if hash curl 2>/dev/null; then
            status_msg "Getting oh-my-zsh with curl"
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        elif hash wget 2>/dev/null; then
            status_msg "Getting oh-my-zsh with wget"
            sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
        else
            status_msg "Cloning oh-my-zsh"
            git clone --recursive https://github.com/robbyrussell/oh-my-zsh "$HOME/.oh-my-zsh" 2>/dev/null
        fi
    else
        warn_msg "oh-my-zsh is already install"
    fi
else
    error_msg "The current shell is not supported"
    exit 1
fi

exit 0
