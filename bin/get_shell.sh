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

_NAME="$0"
_NAME="${_NAME##*/}"
_NOCOLOR=0

# _DEFAULT_SHELL="${SHELL##*/}"
_FORCE_INSTALL=0
_BACKUP=0
_VERBOSE=0

# shellcheck disable=SC2009,SC2046
_CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
_CURRENT_SHELL="${_CURRENT_SHELL##*/}"
_CURRENT_SHELL="${_CURRENT_SHELL##*:}"

# colors
# shellcheck disable=SC2034
black="\033[0;30m"
# shellcheck disable=SC2034
red="\033[0;31m"
# shellcheck disable=SC2034
green="\033[0;32m"
# shellcheck disable=SC2034
yellow="\033[0;33m"
# shellcheck disable=SC2034
blue="\033[0;34m"
# shellcheck disable=SC2034
purple="\033[0;35m"
# shellcheck disable=SC2034
cyan="\033[0;36m"
# shellcheck disable=SC2034
white="\033[0;37;1m"
# shellcheck disable=SC2034
orange="\033[0;91m"
# shellcheck disable=SC2034
normal="\033[0m"
# shellcheck disable=SC2034
reset_color="\033[39m"

function help_user() {
    echo ""
    echo "  Small script to install bash-it or oh-my-zsh shell frameworks"
    echo ""
    echo "  Usage:"
    echo "      $_NAME [OPTIONS]"
    echo "          Ex."
    echo "          $ get_shell"
    echo "          $ get_shell -s bash"
    echo "          $ get_shell -s oh-my-zsh -f"
    echo "          $ get_shell -s bash-it"
    echo ""
    echo "      Optional Flags"
    echo "          --verbose"
    echo "              Output debug messages"
    echo ""
    echo "          --backup"
    echo "              Enable backup of existing files, this flag enables --force but"
    echo "              makes a backup before deletion"
    echo "                  BACKUP_DIR: $HOME/.local/backup"
    echo ""
    echo "          -f, --force"
    echo "              Force installation, remove all previous conflict files before installing"
    echo "              This flag is always disable by default"
    echo ""
    echo "          -s, --shell"
    echo "              Force a shell install. Available: bash/bash-it and zsh/oh-my-zsh"
    echo ""
    echo "          -h, --help"
    echo "              Display help and exit. If you are seeing this, that means that you already know it (nice)"
    echo ""
}

function warn_msg() {
    local warn_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s \n" "$warn_message"
    else
        printf "[!] Warning:\t %s \n" "$warn_message"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s \n" "$error_message" 1>&2
    else
        printf "[X] Error:\t %s \n" "$error_message" 1>&2
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s \n" "$status_message"
    else
        printf "[*] Info:\t %s \n" "$status_message"
    fi
    return 0
}

function verbose_msg() {
    if [[ $_VERBOSE -eq 1 ]]; then
        local debug_message="$1"
        if [[ $_NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s \n" "$debug_message"
        else
            printf "[+] Debug:\t %s \n" "$debug_message"
        fi
    fi
    return 0
}

function rm_framework() {
    local framework_dir="$1"
    if [[ $_BACKUP -eq 1 ]]; then
        mv --backup=numbered "$framework_dir" "$HOME/.local/backup"
    elif [[ $_FORCE_INSTALL -eq 1 ]]; then
        rm -rf "$framework_dir"
    fi
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --nocolor)
            _NOCOLOR=1
            ;;
        --verbose)
            _VERBOSE=1
            ;;
        -s|--shell)
            if [[ -n "$2" ]]; then
                case $2 in
                    bash|bash_it|bash-it)
                        _CURRENT_SHELL="bash"
                        ;;
                    zsh|oh-my-zsh|oh_my_zsh)
                        _CURRENT_SHELL="zsh"
                        ;;
                    *)
                        error_msg "Unsupported shell $2"
                        exit 1
                        ;;
                esac
                shift
            fi
            ;;
        --backup)
            _BACKUP=1
            ;;
        -f|--force)
            _FORCE_INSTALL=1
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

if [[ "$_CURRENT_SHELL" =~ "bash" ]]; then

    rm_framework "$HOME/.bash_it"

    if [[ ! -d "$HOME/.bash_it" ]]; then
        status_msg "Cloning bash-it"
        if [[ $_VERBOSE -eq 1 ]]; then
            if ! git clone --recursive https://github.com/bash-it/bash-it "$HOME/.bash_it"; then
                error_msg "Fail to clone bash-it"
                exit 1
            fi
        else
            if ! git clone --quiet --recursive https://github.com/bash-it/bash-it "$HOME/.bash_it" &>/dev/null; then
                error_msg "Fail to clone bash-it"
                exit 1
            fi
        fi
    else
        warn_msg "Bash-it is already install"
    fi
elif [[ "$_CURRENT_SHELL" =~ "zsh" ]]; then

    rm_framework "$HOME/.oh-my-zsh"

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        status_msg "Cloning oh-my-zsh"
        if [[ $_VERBOSE -eq 1 ]]; then
            if ! git clone --recursive https://github.com/robbyrussell/oh-my-zsh "$HOME/.oh-my-zsh"; then
                error_msg "Fail to clone oh-my-zsh"
                exit 1
            fi
        else
            if ! git clone --quiet --recursive https://github.com/robbyrussell/oh-my-zsh "$HOME/.oh-my-zsh" &>/dev/null; then
                error_msg "Fail to clone oh-my-zsh"
                exit 1
            fi
        fi
    else
        warn_msg "oh-my-zsh is already install"
    fi
else
    error_msg "The current shell is not supported"
    exit 1
fi

exit 0
