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
    echo ""
    echo "  Lists the current directory's files in Vim, so you can edit "
    echo "  it and save to rename them "
    echo ""
    echo "  Don't delete or swap the lines while in Vim or things will get ugly."
    echo ""
    echo "  Credits: https://github.com/thameera/vimv"
    echo ""
    echo "  Usage:"
    echo "      $NAME [OPTIONAL] FILES"
    echo "          Ex."
    echo "          $ $NAME *.mp4"
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

if [ $# -ne 0 ]; then
    src=( "$@" )
else
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

IFS=$'\r\n' GLOBIGNORE='*' command eval  'dest=($(cat /tmp/vimv.$$))'

count=0
for ((i=0;i<${#src[@]};++i)); do
    if [ "${src[i]}" != "${dest[i]}" ]; then
        $MOVE_CMD "${src[i]}" "${dest[i]}"
        ((count++))
    fi
done

echo "$count" files renamed.

rm /tmp/vimv.$$
