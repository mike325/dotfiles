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

function help_user() {
    cat << EOF

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

error_code=0

while [[ $# -gt 0 ]]; do
    filename="$1"

    if [[ -f "$filename" ]]; then
        case "$filename" in
            *.tar|*.tar.*) extraction "$filename" "tar -xf";;
            *.zip|*.ZIP)   extraction "$filename" "unzip";;
            *.pax.Z)       extraction "$filename" "uncompress";;
            *.bz2)         extraction "$filename" "bunzip2";;
            *.dmg)         extraction "$filename" "hdiutil mount";;
            *.pax)         extraction "$filename" "cat";;
            *.rar)         extraction "$filename" "unrar x";;
            *.7z)          extraction "$filename" "7z x";;
            *.gz)          extraction "$filename" "gunzip";;
            *.Z)           extraction "$filename" "uncompress";;
            *) echo " ---- [X] Error '$filename' cannot be extracted/mounted via extract()" ;;
        esac
    else
        error_msg "'$filename' is not a valid file"
        error_code=1
    fi
    shift
done

exit $error_code
