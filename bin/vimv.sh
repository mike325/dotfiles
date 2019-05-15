#!/usr/bin/env bash

#   Description: Lists the current directory's files in Vim, so you can edit
#                it and save to rename them
#
#   Credits: https://github.com/thameera/vimv
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
#            .`                                 `/

NAME="$0"
NAME="${NAME##*/}"

function help_user() {
    cat << EOF

Description:

    Lists the current directory's files in Vim/Neovim, so you can edit
    it and save to rename them

    Don't delete or swap the lines while in Vim/Neovim or things will get ugly.

    Credits: https://github.com/thameera/vimv

Usage:
    $NAME [OPTIONAL] FILES
        Ex.
        $ $NAME *.mp4

    Optional Flags
        -h, --help
            Display help and exit. If you are seeing this, that means that you already know it (nice)

EOF
}

for key in "$@"; do
    case "$key" in
        -h|--help)
            help_user
            exit 0
            ;;
    esac
done

if [ $# -ne 0 ]; then
    src=( "$@" )
else
    # shellcheck disable=SC2016
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'src=($(ls))'
fi

if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    MOVE_CMD='git mv'
else
    MOVE_CMD='mv'
fi

touch /tmp/vimv.$$
for ((i=0;i<${#src[@]};++i)); do
    echo "${src[i]}" >> /tmp/vimv.$$
done

${EDITOR:-vi} /tmp/vimv.$$

# shellcheck disable=SC2016
IFS=$'\r\n' GLOBIGNORE='*' command eval  'dest=($(cat /tmp/vimv.$$))'

count=0
for ((i=0;i<${#src[@]};++i)); do
    # shellcheck disable=SC2154
    if [ "${src[i]}" != "${dest[i]}" ]; then
        $MOVE_CMD "${src[i]}" "${dest[i]}"
        ((count++))
    fi
done

echo "$count" files renamed.

rm /tmp/vimv.$$

exit 0
