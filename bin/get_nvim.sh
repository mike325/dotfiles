#!/usr/bin/env bash
# shellcheck disable=SC2317

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

VERSION="0.1"
AUTHOR=""

VERBOSE=0
QUIET=0
PRINT_VERSION=0
NOCOLOR=0
NOLOG=0
WARN_COUNT=0
ERR_COUNT=0
# FROM_STDIN=()

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"

SCRIPT_PATH="$0"

SCRIPT_PATH="${SCRIPT_PATH%/*}"

OS='unknown'
ARCH="$(uname -m)"

trap '{ exit_append; }' EXIT

TMP='/tmp/'
URL="https://github.com/neovim/neovim"
PYTHON_LIBS=0
RUBY_LIBS=0
# BUILD_LIBS=0
CLONE=0
FORCE_INSTALL=0
PORTABLE=0
INSTALL_DIR="$HOME/.local"
DEV=0
STABLE=0
NVIM_VERSION="latest"

if hash realpath 2>/dev/null; then
    SCRIPT_PATH=$(realpath "$SCRIPT_PATH")
else
    pushd "$SCRIPT_PATH" 1>/dev/null  || exit 1
    SCRIPT_PATH="$(pwd -P)"
    popd 1>/dev/null  || exit 1
fi

if [[ -n $ZSH_NAME ]]; then
    CURRENT_SHELL="zsh"
elif [[ -n $BASH ]]; then
    CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    if [[ -z $CURRENT_SHELL ]]; then
        CURRENT_SHELL="${SHELL##*/}"
    fi
fi

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

case "$SHELL_PLATFORM" in
    # TODO: support more linux distros
    linux)
        if [[ -f /etc/arch-release ]]; then
            OS='arch'
        elif [[ -f /etc/redhat-release ]] && [[ "$(cat /etc/redhat-release)" == Red\ Hat* ]]; then
            OS='redhat'
        elif [[ -f /etc/issue ]] && [[ "$(cat /etc/issue)" == Ubuntu* ]]; then
            OS='ubuntu'
        elif [[ -f /etc/debian_version ]] || [[ "$(cat /etc/issue)" == Debian* ]]; then
            if [[ $ARCH =~ armv.* ]] || [[ $ARCH == aarch64 ]]; then
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
        OS='bsd'
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

if ! hash is_wls 2>/dev/null; then
    function is_wls() {
        if [[ "$(uname -r)" =~ Microsoft ]]; then
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

if ! hash is_root 2>/dev/null; then
    function is_root() {
        if ! is_windows && [[ $EUID -eq 0 ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash has_sudo 2>/dev/null; then
    function has_sudo() {
        if ! is_windows && hash sudo 2>/dev/null && [[ "$(groups)" =~ sudo ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_arm 2>/dev/null; then
    function is_arm() {
        local arch
        arch="$(uname -m)"
        if [[ $arch =~ ^arm ]] || [[ $arch =~ ^aarch ]]; then
            return 0
        fi
        return 1
    }
fi

if ! hash is_64bits 2>/dev/null; then
    function is_64bits() {
        local arch
        arch="$(uname -m)"
        if [[ $arch == 'x86_64' ]] || [[ $arch == 'arm64' ]]; then
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
    cat <<EOF
Description
    Simple script to build and install Neovim directly from the source
    with some pretty basic options.

Usage:
    $NAME [OPTIONAL]

    Optional Flags
        --nolog                 Disable log writing
        --nocolor               Disable color output
        --portable              Download the portable version and place it in $HOME/.local/bin

        -c, --clone             By default this script expect to run under a git directory with
                                the Neovim's source code, this options clone Neovim's repo and move
                                to the repo's root before starts the compile process

        -d, --dir <DIR>         Choose the base root of the repo and move to it before compile
                                the source code, if this options is used with -c/--clone flag
                                it will clone the repo in the desire <DIR>

        -i, --install <PATH>    Path where neovim will be install, default: $INSTALL_DIR
        -p, --python            Install Neovim's python package for python2 and python3
        -r, --ruby              Install Neovim's ruby package
        -f, --force             Ignore errors and warnings and force compilation
        --dev                   Use development builds/portables instead of stable
        --stable                Use stable builds/portables instead of stable
        -C                      Set the compiler, gcc/clang
        -v, --verbose           Enable debug messages
        -q, --quiet             Suppress all output but the errors
        -V, --version           Print script version and exits
        -h, --help              Display this help message
EOF
    # _show_nvim_help
}

function warn_msg() {
    local msg="$1"
    if [[ $QUIET -eq 0 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$msg"
        else
            printf "[!] Warning:\t %s\n" "$msg"
        fi
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
    if [[ $QUIET -eq 0 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "${green}[*] Info:${reset_color}\t %s\n" "$msg"
        else
            printf "[*] Info:\t %s\n" "$msg"
        fi
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

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        error_msg "Internal error in __parse_args function trying to parse $1"
        exit 1
    fi

    local flag="$2"
    local value="$1"

    local pattern="^--${flag}=[a-zA-Z0-9.:@_/~-]+$"

    if [[ -n $3   ]]; then
        local pattern="^--${flag}=$3$"
    fi

    if [[ $value =~ $pattern ]]; then
        local left_side="${value#*=}"
        echo "${left_side/#\~/$HOME}"
    else
        echo "$value"
    fi
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
            printf "[*] Errors:\t%s\n" "$ERR_COUNT" >>"${LOG}"
        fi
    fi
    return 0
}

function raw_output() {
    local msg="echo \"$1\""
    if [[ $NOLOG -eq 0 ]]; then
        msg="$msg | tee -a ${LOG}"
    fi
    if ! sh -c "$msg"; then
            return 1
    fi
    return 0
}

function shell_exec() {
    local cmd="$1"
    if [[ $VERBOSE -eq 1 ]]; then
        if [[ $NOLOG -eq 0 ]]; then
            cmd="$cmd | tee -a ${LOG}"
        fi
        if ! sh -c "$cmd"; then
            return 1
        fi
    elif [[ $NOLOG -eq 0 ]]; then
        if ! sh -c "$cmd >> ${LOG}"; then
            return 1
        fi
    else
        if ! sh -c "$cmd &>/dev/null"; then
            return 1
        fi
    fi
    return 0
}

# mapfile -t VAR < <(cmd)
function parse_cmd_output() {
    local cmd="$1"
    local exit_with_error=0

    # TODO: Read cmd exit code
    while IFS= read -r line; do
        raw_output "$line"
    done < <(sh -c "$cmd")

    # shellcheck disable=SC2086
    return $exit_with_error
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
        --portable=*)
            PORTABLE=1
            _result=$(__parse_args "$key" "portable" '[0-9]\.[0-9](\.[0-9])?')
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid version ${_result##*=}"
                exit 1
            fi
            NVIM_VERSION="v$_result"
            ;;
        --portable)
            PORTABLE=1
            if [[ $2 =~ ^[0-9]\.[0-9](\.[0-9])?$ ]]; then
                NVIM_VERSION="v$2"
                shift
            fi
            ;;
        -f | --force)
            FORCE_INSTALL=1
            ;;
        --compiler=*)
            _result=$(__parse_args "$key" "clone" '^(gcc|clang)$')
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid version ${_result##*=}"
                exit 1
            fi
            export CC="$_result"
            if [[ $CC == gcc ]]; then
                export CXX=g++
            elif [[ $CC == clang ]]; then
                export CXX=clang++
            fi
            if ! hash "$CC" 2>/dev/null; then
                error_msg "Missing compiler C $CC in PATH"
                exit 1
            elif ! hash "$CXX" 2>/dev/null; then
                error_msg "Missing compiler C++ $CXX in PATH"
                exit 1
            fi
            ;;
        -C | --compiler)
            if [[ -z $2 ]]; then
                error_msg "Missing compiler"
                exit 1
            elif [[ ! $2 =~ ^(gcc|clang)$ ]]; then
                error_msg "Invalid compiler $2, please select gcc or clang "
                exit 1
            fi
            export CC="$2"
            shift
            if [[ $CC == gcc ]]; then
                export CXX=g++
            elif [[ $CC == clang ]]; then
                export CXX=clang++
            fi
            if ! hash "$CC" 2>/dev/null; then
                error_msg "Missing compiler C $CC in PATH"
                exit 1
            elif ! hash "$CXX" 2>/dev/null; then
                error_msg "Missing compiler C++ $CXX in PATH"
                exit 1
            fi
            ;;
        --clone=*)
            CLONE=1
            _result=$(__parse_args "$key" "clone" '.+')
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid version ${_result##*=}"
                exit 1
            fi
            CLONE_LOC="$_result"
            ;;
        -c | --clone)
            CLONE=1
            ;;
        -i | --install)
            if [[ -z $2 ]]; then
                error_msg "Missing install path"
                exit 1
            fi
            INSTALL_DIR="$2"
            shift
            ;;
        -p | --python)
            PYTHON_LIBS=1
            ;;
        -r | --ruby)
            RUBY_LIBS=1
            ;;
        # -b | --build)
        #     BUILD_LIBS=1
        #     ;;
        -v | --verbose)
            VERBOSE=1
            ;;
        -q | --quiet)
            QUIET=1
            ;;
        --stable)
            DEV=0
            STABLE=1
            ;;
        --dev)
            DEV=1
            STABLE=0
            ;;
        -V | --version)
            PRINT_VERSION=1
            ;;
        -h | --help)
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

if [[ ! -t 1 ]]; then
    NOCOLOR=1
fi

if [[ $PRINT_VERSION -eq 1 ]]; then
    echo -e "\n$NAME version: ${VERSION}"
    exit 0
fi

initlog
if [[ -n $AUTHOR ]]; then
    verbose_msg "Author         : ${AUTHOR}"
fi
verbose_msg "Script version : ${VERSION}"
verbose_msg "Date           : $(date)"
verbose_msg "Log Disable   : ${NOLOG}"
verbose_msg "Current Shell : ${CURRENT_SHELL}"
verbose_msg "Platform      : ${SHELL_PLATFORM}"
verbose_msg "Architecture  : ${ARCH}"
verbose_msg "OS            : ${OS}"

#######################################################################
#                           CODE Goes Here                            #
#######################################################################

function get_portable() {
    local dir
    local exe_path
    local cmd=''
    local name
    local pkg
    local version
    local build
    local has_backup=false

    if [[ $OS == 'raspbian' ]]; then
        error_msg "There's no neovim portable version for ARM devices"
        return 1
    fi

    if ! hash curl 2>/dev/null && ! hash wget 2>/dev/null; then
        error_msg 'Must have curl or wget to download the latest portable'
        return 1
    fi

    if hash nvim 2>/dev/null && [[ $FORCE_INSTALL -ne 1 ]]; then
        warn_msg "Neovim is already install, use --force to bypass this check"
        return 1
    fi

    if hash curl 2>/dev/null; then
        local cmd='curl -L'
        [[ $VERBOSE -eq 0 ]] && local cmd="${cmd} -s"
    else
        local cmd='wget -q0-'
    fi

    verbose_msg "Using ${cmd} as command"

    if [[ $DEV -eq 0 ]] && [[ $NVIM_VERSION == 'latest' ]]; then
        verbose_msg "Fetching latest stable from ${URL}/tags/"
        version=$( eval "${cmd} ${URL}/tags/ | grep -oE 'v0\.[0-9]\.[0-9]' | sort -u | tail -n 1")
        status_msg "Downloading version: ${version}"
    elif [[ $DEV -eq 1 ]]; then
        status_msg "Downloading Nightly"
    else
        status_msg "Downloading ${NVIM_VERSION}"
    fi

    if is_windows; then
        dir="$HOME/AppData/Roaming/"
        exe_path="$dir/Neovim/nvim"
        name="nvim.zip"
        pkg='nvim-win64.zip'
    elif is_osx; then
        dir="$HOME/.local/bin"
        exe_path="$dir/nvim"
        name="nvim.tar.gz"
        pkg='nvim-macos.tar.gz'
    else
        dir="$HOME/.local/bin"
        exe_path="$dir/nvim"
        name="nvim"
        pkg='nvim.appimage'
    fi

    [[ ! -d $dir ]] && mkdir -p "$dir"

    if [[ $DEV -eq 1 ]]; then
        build='nightly'
    elif [[ $NVIM_VERSION == 'latest' ]]; then
        build="${version}"
    else
        build="v${NVIM_VERSION}"
    fi

    verbose_msg "Downloading ${pkg} from $URL/releases/download/${build}/${pkg} to $TMP/$name"

    if ! eval '${cmd} "$URL/releases/download/${build}/${pkg}" -o "$TMP/$name"'; then
        error_msg "Fail to download neovim"
        return 1
    fi

    [[ ! -d "$HOME/.cache" ]] && mkdir -p "$HOME/.cache"

    if is_windows; then
        verbose_msg "Unpacking ${name}"
        if [[ -d "$dir/Neovim" ]]; then
            verbose_msg "Backing up neovim $dir/Neovim"
            cp -rf "$dir/Neovim" "$HOME/.cache/"
            has_backup=true
        fi
        if ! unzip -qo "$TMP/$name" -d "$dir"; then
            return 1
        fi
        mv "$dir/nvim-win64" "$dir/Neovim"
        rm -rf "${TMP:?}/${name}"
    elif is_osx; then
        pushd "$TMP" >/dev/null  || { error_msg "Could not get to $TMP" && exit 1; }
        verbose_msg "Unpacking ${name}"
        if [[ -f "$dir/nvim" ]]; then
            verbose_msg "Backing up neovim $dir/nvim"
            cp "$dir/nvim" "$HOME/.cache/nvim_backup"
            has_backup=true
        fi
        if ! tar xzvf "$TMP/$name" && mv "${TMP}/nvim-osx64/*" "$dir/"; then
            return 1
        fi
        popd >/dev/null  || { error_msg "Could not get out of $TMP" && exit 1; }
        rm -rf "${TMP:?}/${name}"
        rm -rf "${TMP:?}/nvim-osx64"
    else
        verbose_msg "Installing into $dir/$name"
        if [[ -f "$dir/nvim" ]]; then
            verbose_msg "Backing up neovim $dir/nvim"
            cp "$dir/nvim" "$HOME/.cache/nvim_backup"
            has_backup=true
        fi
        chmod u+x "$TMP/$name" && mv "$TMP/$name" "$dir/$name"
    fi

    if [[ $(file -b "$exe_path" | awk '{print $1}') == 'ASCII' ]]; then
        error_msg "Failed to execute neovim"
        if [[ $has_backup == true ]]; then
            if is_windows; then
                rm -rf "$HOME/AppData/Roaming/Neovim"
                status_msg "Restoring neovim $HOME/.cache/Neovim -> $HOME/AppData/Roaming/Neovim"
                mv "$HOME/.cache/Neovim" "$HOME/AppData/Roaming/Neovim"
            else
                status_msg "Restoring neovim $HOME/.cache/nvim -> $dir/nvim"
                mv "$HOME/.cache/nvim_backup" "$dir/nvim"
            fi
        fi
    fi

    return 0
}

function get_libs() {
    if [[ $PYTHON_LIBS -eq 1 ]]; then
        # hash pip2 2> /dev/null && { status_msg "Installing python2 libs" && pip2 install --upgrade --user pynvim; }
        hash pip3 2>/dev/null  && { status_msg "Installing python3 libs" && pip3 install --upgrade --user pynvim; }
    fi

    if [[ $RUBY_LIBS -eq 1 ]]; then
        hash gem 2>/dev/null  && { status_msg "Installing ruby libs" && gem install --user-install neovim; }
    fi
}

if [[ $PORTABLE -eq 1 ]]; then
    if get_portable; then
        if get_libs; then
            exit 0
        fi
    fi
    exit 1
fi

# Windows stuff
if is_windows; then
    warn_msg "Mingw platform is currently unsupported"
    error_msg "Please follow the official instructions to get Neovim in windows https://github.com/neovim/neovim/wiki/Installing-Neovim#windows"
    exit 1
fi

if hash nvim 2>/dev/null && [[ $FORCE_INSTALL -ne 1 ]]; then
    warn_msg "Neovim is already install, use --force to bypass this check"
    exit 1
fi

if [[ $CLONE -eq 1 ]]; then
    status_msg "Cloning neovim repo"
    if ! shell_exec "git clone --recursive https://github.com/neovim/neovim \"${CLONE_LOC:-.}\""; then
        error_msg "Failed to clone neovim"
        exit 2
    fi
    pushd "${CLONE_LOC:-neovim}" &>/dev/null || { error_msg "Failed to cd into ${CLONE_LOC:-neovim}" && exit 1; }
fi

status_msg "Cleaning current build"
shell_exec "make clean"

BUILD_TYPE="Release"

current_branch="$(git branch --show-current)"
if [[ -z $current_branch ]]; then
    current_branch="$(git rev-parse HEAD)"
fi

if [[ $STABLE -eq 1 ]]; then
    BRANCH="${BRANCH:-origin/release-0.$(git branch --all | awk '/remotes\/origin\/release-/{ gsub("[* ]+remotes/origin/release-0.", "", $0); print $0 }' | sort -n | tail -n1)}"
elif [[ $DEV -eq 1 ]]; then
    BRANCH="master"
    BUILD_TYPE="RelWithDebInfo"
else
    BRANCH="$current_branch"
fi

if [[ $BRANCH != "$current_branch" ]]; then
    status_msg "Checking out to $BRANCH"
    if [[ $BRANCH =~ ^origin/ ]]; then
        shell_exec "git branch --track \"${BRANCH#origin/}\" \"remotes/$BRANCH\""
    fi
    shell_exec "git switch \"${BRANCH#origin/}\""
fi

status_msg "Building neovim"
verbose_msg "Building $BUILD_TYPE on $BRANCH"
if shell_exec "make CMAKE_BUILD_TYPE=$BUILD_TYPE -j"; then
    INSTALL_DIR="${INSTALL_DIR:-$HOME/.local}"
    status_msg "Installing neovim into $INSTALL_DIR"
    if ! shell_exec "make CMAKE_BUILD_TYPE=$BUILD_TYPE CMAKE_INSTALL_PREFIX=\"$INSTALL_DIR\" install"; then
        error_msg "Failed to install neovim"
    fi
else
    error_msg "Failed to compile neovim"
fi

if [[ $CLONE -eq 1 ]]; then
    popd >/dev/null  || exit 1
fi

#######################################################################
#                           CODE Goes Here                            #
#######################################################################
if [[ $ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0
