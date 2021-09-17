#!/usr/bin/env bash

VERBOSE=0

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"
WARN_COUNT=0
ERR_COUNT=0
NOCOLOR=0
NOLOG=0
EDITOR="${EDITOR:-vim}"

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
    cat <<EOF

Description
    Quick edit files using FZF and default editor

Usage:

    $NAME [OPTIONAL]

        Ex.
        $NAME
        $NAME -e ed # uses ed editor

    Optional Flags

        -e, --editor
            Change the default editor
                By default this uses \$EDITOR var and fallback vi in it's unset or empty

        -h, --help
            Display help, if you are seeing this, that means that you already know it (nice)
EOF

}

function warn_msg() {
    local msg="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$msg"
    else
        printf "[!] Warning:\t %s\n" "$msg"
    fi
    WARN_COUNT=$((WARN_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$msg" >>"${LOG}"
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
    ERR_COUNT=$((ERR_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[X] Error:\t %s\n" "$msg" >>"${LOG}"
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
        printf "[*] Info:\t\t %s\n" "$msg" >>"${LOG}"
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
        printf "[+] Debug:\t\t %s\n" "$msg" >>"${LOG}"
    fi
    return 0
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --verbose)
            VERBOSE=1
            ;;
        -e | --editor)
            if [[ -z $2 ]]; then
                error_msg "No editor received"
                exit 1
            elif ! hash "$2" 2>/dev/null; then
                error_msg "Not a valid editor $2"
                exit 1
            fi
            EDITOR="$2"
            shift
            ;;
        -h | --help)
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

fe() {
    local files
    # shellcheck disable=SC2207
    if [[ ! "$(uname -r)" =~ 4\.(4\.0-142|15.0-44) ]]; then
        IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0 --preview-window 'right:60%' --preview '(bat --color=always {} || cat {}) 2> /dev/null' --height=60%))
    else
        IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0 --height=60%))
    fi
    # shellcheck disable=SC2128
    [[ -n $files ]] && ${EDITOR} "${files[@]}"
}

if hash fzf 2>/dev/null; then
    fe "$@"
else
    error_msg "FZF is not install"
    exit 1
fi

exit 0
