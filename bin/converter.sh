#!/usr/bin/env zsh

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
USE_SW_ENCODE=0

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"

if [[ -z $MEDIA_PATH ]]; then
    MEDIA_PATH="$(pwd)"
fi

if [[ -z $ARCHIVE ]]; then
    ARCHIVE="$(pwd)/archive"
fi

SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH%/*}"

OS='unknown'

trap '{ exit_append; }' EXIT
trap '{ clean_up && exit_append && exit 1; }' SIGTERM SIGINT

pushd "$SCRIPT_PATH" 1>/dev/null  || exit 1
SCRIPT_PATH="$(pwd -P)"
popd 1>/dev/null  || exit 1

if [ -z "$SHELL_PLATFORM" ]; then
    if [[ -n $TRAVIS_OS_NAME ]]; then
        export SHELL_PLATFORM="$TRAVIS_OS_NAME"
    else
        case "$OSTYPE" in
            *'linux'*)    export SHELL_PLATFORM='linux' ;;
            *'darwin'*)   export SHELL_PLATFORM='osx' ;;
            *'freebsd'*)  export SHELL_PLATFORM='bsd' ;;
            *'cygwin'*)   export SHELL_PLATFORM='cygwin' ;;
            *'msys'*)     export SHELL_PLATFORM='msys' ;;
            *'windows'*)  export SHELL_PLATFORM='windows' ;;
            *)            export SHELL_PLATFORM='unknown' ;;
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
    cygwin | msys | windows)
        OS='windows'
        ;;
    osx)
        OS='macos'
        ;;
    bsd)
        OS'bsd'
        ;;
esac

if ! hash is_osx 2>/dev/null; then
    function is_osx() {
        if [[ $SHELL_PLATFORM == 'osx' ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_64bits 2>/dev/null; then
    function is_64bits() {
        if [[ $ARCH == 'x86_64' ]] || [[ $ARCH == 'arm64' ]]; then
            return 0
        fi
        return 1
    }
fi

if [[ -n $ZSH_NAME ]]; then
    CURRENT_SHELL="zsh"
elif [[ -n $BASH ]]; then
    CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    # CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
    # CURRENT_SHELL="${CURRENT_SHELL##*/}"
    # CURRENT_SHELL="${CURRENT_SHELL##*:}"
    if [[ -z $CURRENT_SHELL ]]; then
        CURRENT_SHELL="${SHELL##*/}"
    fi
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
    cat <<EOF
Script to automate video conversion to h265/HEVC with 320k aac

Usage:
    $NAME [OPTIONAL]

    Optional Flags
        --nolog                     Disable log writing
        --nocolor                   Disable color output
        -v, --verbose               Enable debug messages
        -o PATH , --output PATH     Set output path
                                        - Default: Same as the origina file
        -a PATH , --archive PATH    Set archive path
                                        - Default: ${ARCHIVE}
        -m PATH , --media PATH      Set media path
                                        - Default: ${MEDIA_PATH}
        -h, --help                  Display this help message
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

    if [[ -n $3 ]]; then
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
    WARN_COUNT=$((WARN_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$warn_message" >>"${LOG}"
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
    ERR_COUNT=$((ERR_COUNT + 1))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[X] Error:\t\t %s\n" "$error_message" >>"${LOG}"
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
        printf "[*] Info:\t\t %s\n" "$status_message" >>"${LOG}"
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
        printf "[+] Debug:\t\t %s\n" "$debug_message" >>"${LOG}"
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
            cat "${SCRIPT_PATH}/shell/banner" >"${LOG}"
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
            printf "\n\n" >>"${LOG}"
        fi

        if [[ $WARN_COUNT -gt 0 ]]; then
            printf "[*] Warnings:\t%s\n" "$WARN_COUNT" >>"${LOG}"
        fi
        if [[ $ERR_COUNT -gt 0 ]]; then
            printf "[*] Errors:\t\t%s\n" "$ERR_COUNT" >>"${LOG}"
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
        -v | --verbose)
            VERBOSE=1
            ;;
        -o | --output)
            if [[ -z ${2} ]]; then
                error_msg "No path for output media path"
                exit 1
            fi
            OUTPUT_DIR="${2}"
            shift
            ;;
        -m | --media)
            if [[ -z ${2} ]]; then
                error_msg "No path for media path"
                exit 1
            fi
            MEDIA_PATH="${2}"
            shift
            ;;
        -a | --archive)
            if [[ -z ${2} ]]; then
                error_msg "No path for archive"
                exit 1
            fi
            ARCHIVE="${2}"
            NO_ARCHIVE=0
            shift
            ;;
        -h | --help)
            help_user
            exit 0
            ;;
        -f | --file)
            if [[ -z $2 ]]; then
                error_msg "No file was provided for $key flag"
                exit 1
            elif [[ ! -f $2 ]]; then
                error_msg "Not a valid file $2"
                exit 1
            fi
            AUTO_LOCATE=0
            FILES+=("$2")
            shift
            ;;
        --sw | --software)
            USE_SW_ENCODE=1
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

    if [[ $name == 'fd' ]]; then
        args=" -uu -t f -e mp4 -e m4a -e mov -e mpge -e 3gp -e mts -e mpge4 --absolute-path . "
    else
        args=" -regextype posix-extended -iregex '.*\.(mp4|m4a|mov|mpge|3gp|mts|mpge4)$' "
    fi

    if [[ $name == 'fd' ]]; then
        cmd="$name $args \"$path\""
    else
        cmd="$name \"$path\" $args"
    fi

    echo "$cmd"
}

function check_sizes() {
    local old_size new_size
    old_size=$(du "$1" | awk '{print $1}')
    new_size=$(du "$2" | awk '{print $1}')
    # local location="$3"

    if [[ $old_size -lt $new_size ]]; then
        warn_msg "Old file $1 is smaller"
        clean_up
        return 1
    fi
    return 0
}

function convert_files() {
    # local file_path="$1"
    local file_dir file_abspath filename file_basename converter vconverter
    local vcodec acodec
    local vcmd=""
    local acmd=""
    local hwaccel=""
    local hevc_encoder=""
    local aconverter=""
    local vcopy="-c:v copy"
    local acopy="-c:a copy"
    local output="$OUTPUT_DIR"
    local default_hw_quality=75
    local default_sw_quality=30

    if is_osx; then
        file_abspath="$1:A"
    else
        file_abspath="$(readlink -f "$1")"
    fi

    file_dir="${file_abspath%/*}"
    filename=$(basename "$file_abspath")
    file_basename=$(basename "${file_abspath%.*}")

    # TODO: support intel quicksync, windows ryzen amf and nvidia accelerators
    hwaccel="$(ffmpeg -hide_banner -hwaccels | grep -iEo '^(vaapi|videotoolbox)$' | head -n1)"
    hevc_encoder="$(ffmpeg -hide_banner -codecs | grep -iEo 'hevc_(vaapi|videotoolbox)')"

    verbose_msg "Hardware encoder: $hwaccel"
    verbose_msg "Hardware h265 encoder: $hevc_encoder"

    verbose_msg "Getting video info"
    if hash ffprobe 2>/dev/null; then
        vcodec="$(ffprobe -v error -select_streams 'v:0' -show_entries stream=codec_name -of default=nokey=1:noprint_wrappers=1 "${file_abspath}")"
        acodec="$(ffprobe -v error -select_streams 'a:0' -show_entries stream=codec_name -of default=nokey=1:noprint_wrappers=1 "${file_abspath}")"
    else
        vcodec="unknown"
        acodec="unknown"
    fi

    verbose_msg "Video codec: $vcodec"
    verbose_msg "Audio codec: $acodec"

    if [[ $vcodec == hevc ]] && { [[ $acodec == aac ]] || [[ $acodec == null ]];  }; then
        warn_msg "Skipping $filename, already hevc with aac"
        return 1
    fi

    local quality=$default_hw_quality
    while true; do
        if [[ -n $hevc_encoder ]] && [[ $USE_SW_ENCODE -eq 0 ]]; then
            status_msg "HW transcode with video with ${quality}"
            if [[ $hwaccel == 'vaapi' ]]; then
                converter="ffmpeg -hwaccel ${hwaccel} -hwaccel_output_format ${hwaccel} -init_hw_device vaapi=encoder:/dev/dri/renderD128 -rc_mode CQP -filter_hw_device encoder -hide_banner"
                vconverter="-c:v ${hevc_encoder} -q:v ${quality} -profile:v main -tier high -level 186 "
            elif [[ $hwaccel == 'videotoolbox' ]]; then
                # Since we are in a mac we can use the audiotoolkit to accelerate audio convertion
                converter="ffmpeg -hwaccel ${hwaccel} -hide_banner "
                vconverter="-c:v ${hevc_encoder} -vtag hvc1 -q:v ${quality} -profile:v main "
                aconverter="-c:a aac_at -b:a 320k -ac 2"
            fi
        else
            status_msg "SW transcode"
            converter="ffmpeg -hide_banner "
            vconverter="-c:v hevc -crf 22 -vtag hvc1 -preset fast -profile:v main "
        fi

        if [[ -z $aconverter ]]; then
            aconverter="-c:a aac -b:a 320k -ac 2"
        fi

        if [[ $VERBOSE -eq 0 ]]; then
            converter="$converter -v quiet "
        else
            converter="$converter -v verbose "
        fi

        vcmd="$vconverter"
        acmd="$aconverter"

        if [[ $vcodec == hevc ]]; then
            vcmd="$vcopy"
        fi

        if [[ $acodec == aac ]] || [[ $acodec == null ]]; then
            acmd="$acopy"
        fi

        status_msg "Converting ${filename}"

        if [[ -z $output ]]; then
            output="${file_dir}"
        fi

        CURRENT="${output}/${file_basename}.hevc.mp4"

        if [[ -f $CURRENT ]]; then
            warn_msg "Skipping $CURRENT, already exists in $output"
            return 0
        fi

        verbose_msg "Converting Video -> ${converter} -i ${file_abspath} ${vcmd} ${acmd} ${CURRENT}"
        if ! eval 'bash -c "${converter} -i \"${file_abspath}\" ${vcmd} ${acmd} \"${CURRENT}\""'; then
            error_msg "Failed to convert video from ${filename}"
            verbose_msg "Cleaning failed file"
            rm -f "${CURRENT}"
            CURRENT=''
            return 1
        fi

        if ! check_sizes "${file_abspath}" "${CURRENT}" "${output}"; then
            if [[ -n $hevc_encoder ]] && [[ $USE_SW_ENCODE -eq 0 ]]; then
                quality=$((quality - 5))
            else
                break
            fi
        else
            break
        fi
    done

    CURRENT=''

    return 0
}

function media_archive() {
    # local file_path="$1"
    local file_dir
    local file_abspath
    local filename
    local file_basename

    if is_osx; then
        file_abspath="$1:A"
    else
        file_abspath="$(readlink -f "$1")"
    fi
    file_dir="${file_abspath%/*}"
    filename=$(basename "$file_abspath")
    file_basename=$(basename "${file_abspath%.*}")

    if [[ ! -d ${ARCHIVE} ]]; then
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

function start_conversion() {
    local _cmd='find'

    if hash fd 2>/dev/null; then
        _cmd='fd'
    fi

    if [[ $AUTO_LOCATE -eq 1 ]]; then
        verbose_msg "Using ${_cmd}"
        CMD="$(get_cmd "$_cmd" "$MEDIA_PATH")"
        verbose_msg "Getting files with -> ${CMD}"

        # readarray -t FILES < <(eval "$CMD")
        while IFS= read -r line; do
            FILES+=("$line")
        done < <(eval "$CMD")
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
    if [[ -f $CURRENT ]]; then
        verbose_msg "Cleaning up last transcoded file $CURRENT"
        rm -f "${CURRENT}" 2>/dev/null
    fi
}

verbose_msg "Using media path at ${MEDIA_PATH}"
verbose_msg "Using archive path at ${ARCHIVE}"

start_conversion

if [[ $ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0
