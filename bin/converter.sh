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

_VERBOSE=0
_NOCOLOR=0
_NOLOG=0
_WARN_COUNT=0
_ERR_COUNT=0
_CURRENT=''
_FILES=()
_AUTO_LOCATE=1

_NAME="$0"
_NAME="${_NAME##*/}"
_LOG="${_NAME%%.*}.log"

if [[ -z "$_MEDIA_PATH" ]]; then
    _MEDIA_PATH="$(pwd)"
fi

if [[ -z "$_ARCHIVE" ]]; then
    _ARCHIVE="/media/video/archive"
fi

_SCRIPT_PATH="$0"
_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

_OS='unknown'

trap '{ exit_append; }' EXIT
trap '{ clean_up; }' SIGTERM SIGINT

if hash realpath 2>/dev/null; then
    _SCRIPT_PATH=$(realpath "$_SCRIPT_PATH")
else
    pushd "$_SCRIPT_PATH" 1> /dev/null || exit 1
    _SCRIPT_PATH="$(pwd -P)"
    popd 1> /dev/null || exit 1
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

_ARCH="$(uname -m)"

case "$SHELL_PLATFORM" in
    # TODO: support more linux distros
    linux)
        if [[ -f /etc/arch-release ]]; then
            _OS='arch'
        elif [[ "$(cat /etc/issue)" == Ubuntu* ]]; then
            _OS='ubuntu'
        elif [[ -f /etc/debian_version ]] || [[ "$(cat /etc/issue)" == Debian* ]]; then
            if [[ $_ARCH == *\ armv7* ]]; then # Raspberry pi 3 uses armv7 cpu
                _OS='raspbian'
            else
                _OS='debian'
            fi
        fi
        ;;
    cygwin|msys|windows)
        _OS='windows'
        ;;
    osx)
        _OS='macos'
        ;;
    bsd)
        _OS='bsd'
        ;;
esac

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

if [[ -n "$ZSH_NAME" ]]; then
    _CURRENT_SHELL="zsh"
elif [[ -n "$BASH" ]]; then
    _CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    # _CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
    # _CURRENT_SHELL="${_CURRENT_SHELL##*/}"
    # _CURRENT_SHELL="${_CURRENT_SHELL##*:}"
    if [[ -z "$_CURRENT_SHELL" ]]; then
        _CURRENT_SHELL="${SHELL##*/}"
    fi
fi

if ! hash is_64bits 2>/dev/null; then
    # TODO: This should work with ARM 64bits
    function is_64bits() {
        if [[ $_ARCH == 'x86_64' ]]; then
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
Script to automate video convertion to h265 with 320k aac

Usage:
    $_NAME [OPTIONAL]

    Optional Flags

        --nolog
            Disable log writting

        --nocolor
            Disable color output

        -v, --verbose
            Enable debug messages

        -a PATH , --archive PATH
            Set archive path
                - Default: ${_ARCHIVE}

        -m PATH , --media PATH
            Set media path
                - Default: ${_MEDIA_PATH}

        -h, --help
            Display help, if you are seeing this, that means that you already know it (nice)
EOF
}

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        error_msg "Internal error in __parse_args function trying to parse $1"
        exit 1
    fi

    local arg="$1"
    local converter="$2"

    local pattern="^--${converter}=[a-zA-Z0-9.:@_/~-]+$"

    if [[ -n "$3" ]]; then
        local pattern="^--${converter}=$3$"
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
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$warn_message"
    else
        printf "[!] Warning:\t %s\n" "$warn_message"
    fi
    _WARN_COUNT=$(( _WARN_COUNT + 1 ))
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$warn_message" >> "${_LOG}"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$error_message" 1>&2
    else
        printf "[X] Error:\t %s\n" "$error_message" 1>&2
    fi
    _ERR_COUNT=$(( _ERR_COUNT + 1 ))
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[X] Error:\t\t %s\n" "$error_message" >> "${_LOG}"
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s\n" "$status_message"
    else
        printf "[*] Info:\t %s\n" "$status_message"
    fi
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$status_message" >> "${_LOG}"
    fi
    return 0
}

function verbose_msg() {
    local debug_message="$1"
    if [[ $_VERBOSE -eq 1 ]]; then
        if [[ $_NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$debug_message"
        else
            printf "[+] Debug:\t %s\n" "$debug_message"
        fi
    fi
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$debug_message" >> "${_LOG}"
    fi
    return 0
}

function initlog() {
    if [[ $_NOLOG -eq 0 ]]; then
        rm -f "${_LOG}" 2>/dev/null
        if ! touch "${_LOG}" &>/dev/null; then
            error_msg "Fail to init log file"
            _NOLOG=1
            return 1
        fi
        if [[ -f "${_SCRIPT_PATH}/shell/banner" ]]; then
            cat "${_SCRIPT_PATH}/shell/banner" > "${_LOG}"
        fi
        if ! is_osx; then
            _LOG=$(readlink -e "${_LOG}")
        fi
        verbose_msg "Using log at ${_LOG}"
    fi
    return 0
}

function exit_append() {
    if [[ $_NOLOG -eq 0 ]]; then
        if [[ $_WARN_COUNT -gt 0 ]] || [[ $_ERR_COUNT -gt 0 ]]; then
            printf "\n\n" >> "${_LOG}"
        fi

        if [[ $_WARN_COUNT -gt 0 ]]; then
            printf "[*] Warnings:\t%s\n" "$_WARN_COUNT" >> "${_LOG}"
        fi
        if [[ $_ERR_COUNT -gt 0 ]]; then
            printf "[*] Errors:\t\t%s\n" "$_ERR_COUNT" >> "${_LOG}"
        fi
    fi
    return 0
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --nolog)
            _NOLOG=1
            ;;
        --nocolor)
            _NOCOLOR=1
            ;;
        -v|--verbose)
            _VERBOSE=1
            ;;
        -m|--media)
            if [[ -z "${2}" ]]; then
                error_msg "No path for media path"
                exit 1
            fi
            _MEDIA_PATH="${2}"
            shift
            ;;
        -a|--archive)
            if [[ -z "${2}" ]]; then
                error_msg "No path for archive"
                exit 1
            fi
            _ARCHIVE="${2}"
            shift
            ;;
        -h|--help)
            help_user
            exit 0
            ;;
        -f|--file)
            if [[ -z "$2" ]]; then
                error_msg "No file was provided for $key flag"
                exit 1
            elif [[ ! -f "$2" ]]; then
                error_msg "Not a valid file $2"
                exit 1
            fi
            _AUTO_LOCATE=0
            _FILES+=("$2")
            shift
            ;;
        -)
            while read -r from_stdin; do
                _AUTO_LOCATE=0
                _FILES+=("$from_stdin")
            done
            break
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

verbose_msg "Log Disable   : ${_NOLOG}"
verbose_msg "Current Shell : ${_CURRENT_SHELL}"
verbose_msg "Platform      : ${SHELL_PLATFORM}"
verbose_msg "OS Name       : ${_OS}"
verbose_msg "Architecture  : ${_ARCH}"

if ! hash ffmpeg 2>/dev/null; then
    error_msg "Failed to locate ffmpeg"
    exit 1
fi

function get_cmd() {
    local name="$1"
    local path="$2"
    local cmd
    local args

    if [[ "$name" == 'fd' ]]; then
        args=" -t f -e mp4 --absolute-path . "
    else
        args=" -regextype posix-extended -iregex '.*\.mp4$' "
    fi

    if [[ "$name" == 'fd' ]]; then
        cmd="$name $args $path"
    else
        cmd="$name $path $args"
    fi

    echo "$cmd"
}

function convert_files() {
    # local file_path="$1"
    local file_dir
    local file_abspath
    local filename
    local file_basename

    file_abspath="$(readlink -f "$1")"
    file_dir="${file_abspath%/*}"
    filename=$(basename "$file_abspath")
    file_basename=$(basename "${file_abspath%.*}")

    local converter="ffmpeg -hwaccel auto -hide_banner"
    local vconverter="-c:v libx265 -crf 16 -preset slow -x265-params lossless"
    local aconverter="-c:a aac -b:a 320k"
    local vcopy="-c:v copy"
    local acopy="-c:a copy"
    local vcodec
    local acodec

    if [[ $_VERBOSE -eq 0 ]]; then
        converter="$converter -v quiet "
    fi

    # local metadata=" --metadata authr=$_AUTHOR"

    verbose_msg "Getting video info"

    if hash ffprobe 2>/dev/null && hash jq 2>/dev/null; then
        vcodec="$(ffprobe -v quiet -show_format -show_streams -print_format json -hide_banner -i "${file_abspath}" |  jq .streams[0].codec_name | cut -f2 -d'"')"
        acodec="$(ffprobe -v quiet -show_format -show_streams -print_format json -hide_banner -i "${file_abspath}" |  jq .streams[1].codec_name | cut -f2 -d'"')"
    fi

    verbose_msg "Video codec: $vcodec"
    verbose_msg "Audio codec: $acodec"

    if [[ "$vcodec" == hevc ]] && { [[ "$acodec" == aac ]] || [[ "$acodec" == null ]] ; }; then
        warn_msg "Skipping $filename, already h265 with aac"
        return 1
    fi

    local vcmd="$vconverter"
    local acmd="$aconverter"

    if [[ "$vcodec" == hevc ]]; then
        vcmd="$vcopy"
    fi

    if [[ "$acodec" == aac ]] || [[ "$acodec" == null ]]; then
        acmd="$acopy"
    fi

    status_msg "Converting ${filename}"

    _CURRENT="${file_dir}/${file_basename}.265.mp4"

    verbose_msg "Converting Video -> ${converter} -i ${file_abspath} ${vcmd} ${acmd} ${file_dir}/${file_basename}.265.mp4"
    if ! eval '${converter} -i "${file_abspath}" ${vcmd} ${acmd} "${file_dir}/${file_basename}.265.mp4"'; then
        error_msg "Failed to convert video from ${filename}"
        verbose_msg "Cleaning failed file"
        rm -f "${file_dir}/${file_basename}.265.mp4"
        _CURRENT=''
        return 1
    fi

    _CURRENT=''

    return 0
}

function media_archive() {
    # local file_path="$1"
    local file_dir
    local file_abspath
    local filename
    local file_basename

    file_abspath="$(readlink -f "$1")"
    file_dir="${file_abspath%/*}"
    filename=$(basename "$file_abspath")
    file_basename=$(basename "${file_abspath%.*}")

    if [[ ! -d "${_ARCHIVE}" ]]; then
        verbose_msg "Creating archive ${_ARCHIVE}"
        mkdir -p "${_ARCHIVE}"
    fi

    if hash fd 2>/dev/null; then
        file_list="$(fd -t f -e mp4 . "${_ARCHIVE}" | wc -l)"
    else
        file_list="$(find "${_ARCHIVE}" -regextype posix-extended -iregex '.*\.mp4$' | wc -l)"
    fi

    status_msg "Backing up original file ${filename}"
    verbose_msg "Using -> mv --backup=numbered ${file_abspath} ${_ARCHIVE}/"

    if ! mv --backup=numbered "${file_abspath}" "${_ARCHIVE}/"; then
        error_msg "Failed to backup ${filename}"
        return 1
    fi

    if [[ -f "${file_dir}/${file_basename}M01.XML" ]]; then
        status_msg "Backing up sidecard file: ${file_basename}M01.XML"
        verbose_msg "Using -> cp --backup=numbered ${file_dir}/${file_basename}M01.XML ${_ARCHIVE}/C${file_list}M01.XML"
        if ! cp --backup=numbered "${file_dir}/${file_basename}M01.XML" "${_ARCHIVE}/C${file_list}M01.XML"; then
            error_msg "Failed to backup sidecard file ${file_dir}/${file_basename}M01.XML"
            return 1
        fi
    fi

    return 0
}

function start_convertion() {
    local _cmd='find'

    if hash fd 2>/dev/null; then
        _cmd='fd'
    fi

    if [[ $_AUTO_LOCATE -eq 1 ]]; then
        verbose_msg "Using ${_cmd}"
        _CMD="$(get_cmd "$_cmd" "$_MEDIA_PATH")"
        verbose_msg "Getting files with -> ${_CMD}"
        mapfile -t _FILES < <(eval "$_CMD")
    else
        verbose_msg "Converting input files:"
        for i in "${_FILES[@]}"; do
            printf "\t%s\n" "$i" | tee -a "${_LOG}"
        done
    fi

    for i in "${_FILES[@]}"; do
        if convert_files "${i}"; then
            if ! media_archive "${i}"; then
                error_msg "Failed to archive ${i}"
            fi
        fi
    done

}

function clean_up() {
    verbose_msg "Cleaning up by interrupt"
    if [[ -f "$_CURRENT" ]]; then
        verbose_msg "Cleanning incomplete video $_CURRENT" && rm -f "${_CURRENT}" 2>/dev/null
    fi
    exit_append
    exit 1
}

verbose_msg "Using media path at ${_MEDIA_PATH}"
verbose_msg "Using archive path at ${_ARCHIVE}"

start_convertion

if [[ $_ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0
