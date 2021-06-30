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
CURRENT=''
FILES=()
AUTO_LOCATE=1
NO_ARCHIVE=1
OUTPUT_DIR=""

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"

if [[ -z "$MEDIA_PATH" ]]; then
    MEDIA_PATH="$(pwd)"
fi

if [[ -z "$ARCHIVE" ]]; then
    ARCHIVE="$(pwd)/archive"
fi

SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH%/*}"

OS='unknown'

trap '{ exit_append; }' EXIT
trap '{ clean_up && exit_append && exit 1; }' SIGTERM SIGINT

if hash realpath 2>/dev/null; then
    SCRIPT_PATH=$(realpath "$SCRIPT_PATH")
else
    pushd "$SCRIPT_PATH" 1> /dev/null || exit 1
    SCRIPT_PATH="$(pwd -P)"
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

ARCH="$(uname -m)"

case "$SHELL_PLATFORM" in
    # TODO: support more linux distros
    linux)
        if [[ -f /etc/arch-release ]]; then
            OS='arch'
        elif [[ "$(cat /etc/issue)" == Ubuntu* ]]; then
            OS='ubuntu'
        elif [[ -f /etc/debian_version ]] || [[ "$(cat /etc/issue)" == Debian* ]]; then
            if [[ $ARCH == *\ armv7* ]]; then # Raspberry pi 3 uses armv7 cpu
                OS='raspbian'
            else
                OS='debian'
            fi
        fi
        ;;
    cygwin|msys|windows)
        OS='windows'
        ;;
    osx)
        OS='macos'
        ;;
    bsd)
        OS'bsd'
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
    CURRENT_SHELL="zsh"
elif [[ -n "$BASH" ]]; then
    CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    # CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
    # CURRENT_SHELL="${CURRENT_SHELL##*/}"
    # CURRENT_SHELL="${CURRENT_SHELL##*:}"
    if [[ -z "$CURRENT_SHELL" ]]; then
        CURRENT_SHELL="${SHELL##*/}"
    fi
fi

if ! hash is_64bits 2>/dev/null; then
    # TODO: This should work with ARM 64bits
    function is_64bits() {
        if [[ $ARCH == 'x86_64' ]]; then
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
    $NAME [OPTIONAL]

    Optional Flags

        --nolog
            Disable log writting

        --nocolor
            Disable color output

        -v, --verbose
            Enable debug messages

        -o PATH , --output PATH
            Set output path
                - Default: Same as the origina file

        -a PATH , --archive PATH
            Set archive path
                - Default: ${ARCHIVE}

        -m PATH , --media PATH
            Set media path
                - Default: ${MEDIA_PATH}

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
        rm -f "${LOG}" 2>/dev/null
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
        -o|--output)
            if [[ -z "${2}" ]]; then
                error_msg "No path for output media path"
                exit 1
            fi
            OUTPUT_DIR="${2}"
            shift
            ;;
        -m|--media)
            if [[ -z "${2}" ]]; then
                error_msg "No path for media path"
                exit 1
            fi
            MEDIA_PATH="${2}"
            shift
            ;;
        -a|--archive)
            if [[ -z "${2}" ]]; then
                error_msg "No path for archive"
                exit 1
            fi
            ARCHIVE="${2}"
            NO_ARCHIVE=0
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
            AUTO_LOCATE=0
            FILES+=("$2")
            shift
            ;;
        -)
            while read -r from_stdin; do
                AUTO_LOCATE=0
                FILES=("$from_stdin")
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

verbose_msg "Log Disable   : ${NOLOG}"
verbose_msg "Current Shell : ${CURRENT_SHELL}"
verbose_msg "Platform      : ${SHELL_PLATFORM}"
verbose_msg "OS Name       : ${OS}"
verbose_msg "Architecture  : ${ARCH}"

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
        args=" -uu -t f -e m4a -e mp4 --absolute-path . "
    else
        args=" -regextype posix-extended -iregex '.*\.(mp4|m4a)$' "
    fi

    if [[ "$name" == 'fd' ]]; then
        cmd="$name $args \"$path\""
    else
        cmd="$name \"$path\" $args"
    fi

    echo "$cmd"
}

function check_sizes() {
    local old_size new_size location
    old_size=$(du "$1" | awk '{print $1}')
    new_size=$(du "$2" | awk '{print $1}')
    location="$3"

    if [[ $old_size -lt $new_size ]]; then
        warn_msg "Old file $1 is smaller"
        clean_up
        # if [[ ! -f "${location}/$1" ]]; then
        #     status_msg "Copying old file"
        #     verbose_msg "Using -> cp '$1' '${location}'"
        #     if ! cp "$1" "${location}/"; then
        #         error_msg "Failed to move old file '$1' to new location"
        #         return 1
        #     fi
        # else
        #     status_msg "Skipping $1, already exits in ${location}"
        # fi
    fi

    return 0
}

function convert_files() {
    # local file_path="$1"
    local file_dir
    local file_abspath
    local filename
    local file_basename
    # local has_hwaccel=false
    local converter
    local vconverter
    local file_dir file_abspath filename file_basename
    local converter vconverter
    local output="$OUTPUT_DIR"

    file_abspath="$(readlink -f "$1")"
    file_dir="${file_abspath%/*}"
    filename=$(basename "$file_abspath")
    file_basename=$(basename "${file_abspath%.*}")

    if hash vainfo 2>/dev/null && { vainfo 2>/dev/null | grep -qi hevc; }; then
        converter="ffmpeg -hwaccel vaapi -hwaccel_output_format vaapi -init_hw_device vaapi=encoder:/dev/dri/renderD128 -filter_hw_device encoder -hide_banner"
        vconverter="-c:v hevc_vaapi -rc_mode 1 -crf 0 -qp 25 -profile:v main -tier high -level 186 "
    else
        converter="ffmpeg -hwaccel auto -hide_banner "
        vconverter="-c:v hevc -crf 0 -preset slow"
    fi

    local aconverter="-c:a aac -b:a 320k"
    local vcopy="-c:v copy"
    local acopy="-c:a copy"
    local vcodec
    local acodec

    if [[ $VERBOSE -eq 0 ]]; then
        converter="$converter -v quiet "
    else
        converter="$converter -v verbose "
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

    if [[ -z $output ]]; then
        output="${file_dir}"
    fi

    CURRENT="${output}/${file_basename}.265.mp4"

    if [[ -f "$CURRENT" ]]; then
        warn_msg "Skipping $CURRENT, already exists in $output"
        return 0
    fi

    verbose_msg "Converting Video -> ${converter} -i ${file_abspath} ${vcmd} ${acmd} ${CURRENT}"
    if ! eval '${converter} -i "${file_abspath}" ${vcmd} ${acmd} "${CURRENT}"'; then
        error_msg "Failed to convert video from ${filename}"
        verbose_msg "Cleaning failed file"
        rm -f "${CURRENT}"
        CURRENT=''
        return 1
    fi

    check_sizes "${file_abspath}" "${CURRENT}" "${output}"

    CURRENT=''

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

    if [[ ! -d "${ARCHIVE}" ]]; then
        verbose_msg "Creating archive ${ARCHIVE}"
        mkdir -p "${ARCHIVE}"
    fi

    status_msg "Backing up original file ${filename}"
    verbose_msg "Using -> mv --backup=numbered ${file_abspath} ${ARCHIVE}/"

    if ! mv --backup=numbered "${file_abspath}" "${ARCHIVE}/"; then
        error_msg "Failed to backup ${filename}"
        return 1
    fi

    if [[ -f "${file_dir}/${file_basename}M01.XML" ]]; then
        status_msg "Backing up sidecard file: ${file_basename}M01.XML"
        verbose_msg "Using -> cp --backup=numbered ${file_dir}/${file_basename}M01.XML ${ARCHIVE}/"
        if ! cp --backup=numbered "${file_dir}/${file_basename}M01.XML" "${ARCHIVE}/"; then
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

    if [[ $AUTO_LOCATE -eq 1 ]]; then
        verbose_msg "Using ${_cmd}"
        CMD="$(get_cmd "$_cmd" "$MEDIA_PATH")"
        verbose_msg "Getting files with -> ${CMD}"
        mapfile -t FILES < <(eval "$CMD")
    else
        verbose_msg "Converting input files:"
        for i in "${FILES[@]}"; do
            printf "\t%s\n" "$i" | tee -a "${LOG}"
        done
    fi

    for i in "${FILES[@]}"; do
        if convert_files "${i}"; then
            if [[ $NO_ARCHIVE -eq 0 ]]; then
                if ! media_archive "${i}"; then
                    # TODO
                    error_msg "TODO"
                    exit 1
                fi
            fi
        fi
    done

}

function clean_up() {
    if [[ -f "$CURRENT" ]]; then
        verbose_msg "Cleaning up last transcoded file $CURRENT"
        rm -f "${CURRENT}" 2>/dev/null
    fi
}

verbose_msg "Using media path at ${MEDIA_PATH}"
verbose_msg "Using archive path at ${ARCHIVE}"

start_convertion

if [[ $ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0
