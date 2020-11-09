#!/usr/bin/env bash

VERBOSE=0

NAME="$0"
NAME="${NAME##*/}"
EDITOR="${EDITOR:-vim}"

function help_user() {
    cat<<EOF

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
    local warn_message="$1"
    printf "[!]     ---- Warning!!! %s \n" "$warn_message"
}

function error_msg() {
    local error_message="$1"
    printf "[X]     ---- Error!!!   %s \n" "$error_message" 1>&2
}

function status_msg() {
    local status_message="$1"
    printf "[*]     ---- %s \n" "$status_message"
}

function verbose_msg() {
    if [[ $VERBOSE -eq 1 ]]; then
        local debug_message="$1"
        printf "[+]     ---- Debug!!!   %s \n" "$debug_message"
    fi
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --verbose)
            VERBOSE=1
            ;;
        -e|--editor)
            if [[ -z "$2" ]]; then
                error_msg "No editor received"
                exit 1
            elif ! hash "$2" 2> /dev/null; then
                error_msg "Not a valid editor $2"
                exit 1
            fi
            EDITOR="$2"
            shift
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

fe() {
    local files
    # shellcheck disable=SC2207
    if [[ ! "$(uname -r)" =~ 4\.(4\.0-142|15.0-44) ]]; then
        IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0 --preview-window 'right:60%' --preview '(bat --color=always {} || cat {}) 2> /dev/null'))
    else
        IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0))
    fi
    # shellcheck disable=SC2128
    [[ -n "$files" ]] && ${EDITOR} "${files[@]}"
}

if hash fzf 2>/dev/null; then
    fe "$@"
else
    error_msg "FZF is not install"
    exit 1
fi

exit 0
