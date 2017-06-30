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

for key in "$@"; do
    case "$key" in
        -h|--help)
            help_user
            exit 0
            ;;
    esac
done

if [[ "$SHELL" =~ "bash" ]] && [[ ! -d "$HOME/.bash_it" ]]; then
    git clone --recursive https://github.com/bash-it/bash-it "$HOME/.bash_it" 2>/dev/null
elif [[ "$SHELL" =~ "zsh" ]] && [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    if hash curl 2>/dev/null; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    elif hash wget 2>/dev/null; then
        sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    else
        git clone --recursive https://github.com/robbyrussell/oh-my-zsh "$HOME/.oh-my-zsh" 2>/dev/null
    fi
else
    echo "    ---- [X] Error the current shell is not supported"
fi
