#!/usr/bin/env bash

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
#            .`                                 `/

VERBOSE=0
NOCOLOR=0
NOLOG=0
WARN_COUNT=0
ERR_COUNT=0

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"

SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH%/*}"

trap '{ exit_append; }' EXIT

if hash realpath 2>/dev/null; then
    SCRIPT_PATH=$(realpath "$SCRIPT_PATH")
else
    pushd "$SCRIPT_PATH" 1> /dev/null || exit 1
    SCRIPT_PATH="$(pwd -P)"
    popd 1> /dev/null || exit 1
fi

if [[ -n "$ZSH_NAME" ]]; then
    CURRENT_SHELL="zsh"
elif [[ -n "$BASH" ]]; then
    CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    if [[ -z "$CURRENT_SHELL" ]]; then
        CURRENT_SHELL="${SHELL##*/}"
    fi
fi

if [ -z "$SHELL_PLATFORM" ]; then
    if [[ -n $TRAVIS_OS_NAME ]]; then
        export SHELL_PLATFORM="$TRAVIS_OS_NAME"
    else
        case "$OSTYPE" in
            *'linux'*   ) export SHELL_PLATFORM='linux' ;;
            *'darwin'*  ) export SHELL_PLATFORM='osx' ;;
            *'freebsd'* ) export SHELL_PLATFORM='bsd' ;;
            *'cygwin'*  ) export SHELL_PLATFORM='cygwin' ;;
            *'msys'*    ) export SHELL_PLATFORM='msys' ;;
            *'windows'* ) export SHELL_PLATFORM='windows' ;;
            *           ) export SHELL_PLATFORM='unknown' ;;
        esac
    fi
fi

if ! hash is_windows 2>/dev/null; then
    function is_windows() {
        if [[ $SHELL_PLATFORM =~ (msys|cygwin|windows) ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_wsl 2>/dev/null; then
    function is_wsl() {
        if [[ "$(uname -r)" =~ Microsoft ]] ; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_osx 2>/dev/null; then
    function is_osx() {
        if [[ $SHELL_PLATFORM == 'osx' ]]; then
            return 0
        fi
        return 1
    }
fi

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
    cat<<EOF
Description
    Lint project source code

Usage:
    $NAME [OPTIONAL]

    Optional Flags

        --nolog
            Disable log writting

        --nocolor
            Disable color output

        -v, --verbose
            Enable debug messages

        -h, --help
            Display help, if you are seeing this, that means that you already know it (nice)
EOF
}

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        echo ""
    fi

    local arg="$1"
    local basic="$2"

    local pattern="^--${basic}[=][a-zA-Z0-9._-/~]+$"

    if [[ -n "$3" ]]; then
        local pattern="^--${basic}[=]$3$"
    fi

    if [[ $arg =~ $pattern ]]; then
        local left_side="${arg#*=}"
        echo "${left_side/#\~/$HOME}"
    else
        echo "$arg"
    fi
}

function warn_msg() {
    local warn_message="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$warn_message"
    else
        printf "[!] Warning:\t %s\n" "$warn_message"
    fi
    WARN_COUNT=$(( WARN_COUNT + 1 ))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$warn_message" >> "${LOG}"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$error_message" 1>&2
    else
        printf "[X] Error:\t %s\n" "$error_message" 1>&2
    fi
    ERR_COUNT=$(( ERR_COUNT + 1 ))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[X] Error:\t\t %s\n" "$error_message" >> "${LOG}"
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s\n" "$status_message"
    else
        printf "[*] Info:\t %s\n" "$status_message"
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$status_message" >> "${LOG}"
    fi
    return 0
}

function verbose_msg() {
    local debug_message="$1"
    if [[ $VERBOSE -eq 1 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$debug_message"
        else
            printf "[+] Debug:\t %s\n" "$debug_message"
        fi
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$debug_message" >> "${LOG}"
    fi
    return 0
}

function initlog() {
    if [[ $NOLOG -eq 0 ]]; then
        [[ -n $LOG ]] && rm -f "${LOG}" 2>/dev/null
        if ! touch "${LOG}" &>/dev/null; then
            error_msg "Fail to init log file"
            NOLOG=1
            return 1
        fi
        if [[ -f "${SCRIPT_PATH}/shell/banner" ]]; then
            cat "${SCRIPT_PATH}/shell/banner" > "${LOG}"
        fi
        if ! is_osx; then
            LOG=$(readlink -e "${LOG}")
        fi
        verbose_msg "Using log at ${LOG}"
    fi
    return 0
}

function exit_append() {
    if [[ $NOLOG -eq 0 ]]; then
        if [[ $WARN_COUNT -gt 0 ]] || [[ $ERR_COUNT -gt 0 ]]; then
            printf "\n\n" >> "${LOG}"
        fi

        if [[ $WARN_COUNT -gt 0 ]]; then
            printf "[*] Warnings:\t%s\n" "$WARN_COUNT" >> "${LOG}"
        fi
        if [[ $ERR_COUNT -gt 0 ]]; then
            printf "[*] Errors:\t\t%s\n" "$ERR_COUNT" >> "${LOG}"
        fi
    fi
    return 0
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --nolog)
            NOLOG=1
            ;;
        --nocolor)
            NOCOLOR=1
            ;;
        -v|--verbose)
            VERBOSE=1
            ;;
        -h|--help)
            help_user
            exit 0
            ;;
        *)
            initlog
            error_msg "Unknown argument $key"
            help_user
            exit 1
            ;;
    esac
    shift
done

initlog

# Make sure path have local bin
# shellcheck disable=SC2034
PATH="$HOME/.local/bin/:$PATH"

if ! hash shellcheck 2>/dev/null; then
    error_msg 'Missing shellcheck, aborting basic test'
    exit 1
fi

status_msg 'Starting shellcheck test'
version="$(shellcheck --version | grep 'version:' | grep -oE '[0-9]\.[0-9]\.[0-9]')"
verbose_msg "Shellcheck version: ${version}"

# shellcheck disable=SC2046
if [[ $version =~ 0\.[0-3]\.[0-9] ]]; then
    warn_msg "Shellcheck is too old, skipping"
elif [[ $version =~ 0\.[4-5]\.[0-9] ]]; then
    if ! shellcheck -x -e 1117 $(find . -iname '*.sh' ! -iname 'zsh.sh'  ! -path '*/shell/scripts/*' ! -path '*/shell/host/*'); then
        error_msg 'Fail shellcheck test'
        exit 2
    fi
else
    if ! shellcheck -x -a -e 1117 $(find . -iname '*.sh' ! -iname 'zsh.sh'  ! -path '*/shell/scripts/*' ! -path '*/shell/host/*'); then
        error_msg 'Fail shellcheck test'
        exit 2
    fi
fi

status_msg 'Starting python lint test'
verbose_msg "Flake version: $(flake8 --version)"

if ! flake8 --max-line-length=120 --max-complexity=18; then
    error_msg "Failed python lint test"
    exit 3
fi

exit 0
