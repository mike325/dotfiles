#!/usr/bin/env bash

#   Author: Credit: http://nparikh.org/notes/zshrc.txt
#   Description: Extract any given number of compressed files
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
LOG="${NAME%%.*}.log"
WARN_COUNT=0
ERR_COUNT=0
NOCOLOR=0
NOLOG=0

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

Description:
    Extract any given number of compressed files

Usage:
    $NAME FILE(S) [OPTIONAL]
        Ex.
        $NAME file.zip stuff.tar foo.rar

Optional Flags
    -h, --help
        Display help and exit. If you are seeing this, that means that you already know it (nice)

EOF
}

function extraction() {
    local filename="$1"
    local cmd="$2"

    echo "[*] Extracting $filename"
    sh -c "$cmd $filename 1> /dev/null"
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

for key in "$@"; do
    case "$key" in
        -h | --help)
            help_user
            exit 0
            ;;
    esac
done

error_code=0

while [[ $# -gt 0 ]]; do
    filename="$1"

    if [[ -f $filename ]]; then
        case "$filename" in
            *.tar | *.tar.*) extraction "$filename" "tar -xf" ;;
            *.zip | *.ZIP) extraction "$filename" "unzip" ;;
            *.pax.Z)       extraction "$filename" "uncompress" ;;
            *.bz2)         extraction "$filename" "bunzip2" ;;
            *.dmg)         extraction "$filename" "hdiutil mount" ;;
            *.pax)         extraction "$filename" "cat" ;;
            *.rar)         extraction "$filename" "unrar x" ;;
            *.7z)          extraction "$filename" "7z x" ;;
            *.gz)          extraction "$filename" "gunzip" ;;
            *.Z)           extraction "$filename" "uncompress" ;;
            *) echo " ---- [X] Error '$filename' cannot be extracted/mounted via extract()" ;;
        esac
    else
        error_msg "'$filename' is not a valid file"
        error_code=1
    fi
    shift
done

exit $error_code
