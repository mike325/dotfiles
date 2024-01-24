#!/usr/bin/env bash

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
URL="https://github.com/neovim/neovim"
PYTHON_LIBS=0
RUBY_LIBS=0
# BUILD_LIBS=0
CLONE=0
FORCE_INSTALL=0
PORTABLE=0
VERBOSE=0
DEV=0
STABLE=0
NOLOG=1
NOCOLOR=0

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"

WARN_COUNT=0
ERR_COUNT=0

NVIM_VERSION="latest"

OS='unknown'

TMP='/tmp/'

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
        elif [[ "$(cat /etc/issue)" == Ubuntu* ]]; then
            OS='ubuntu'
        elif [[ -f /etc/debian_version ]]; then
            if [[ "$(uname -a)" == *\ armv7* ]]; then # Raspberry pi 3 uses armv7 cpu
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

# _ARCH="$(uname -m)"

if ! hash is_windows 2>/dev/null; then
    function is_windows() {
        if [[ $SHELL_PLATFORM =~ (msys|cygwin|windows) ]]; then
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

function show_help() {
    cat <<EOF
Simple script to build and install Neovim directly from the source
with some pretty basic options.

Usage:
    $NAME [OPTIONS]

    Optional Flags
        --portable
            Download the portable version and place it in $HOME/.local/bin

        -c, --clone             By default this script expect to run under a git directory with
                                the Neovim's source code, this options clone Neovim's repo and move
                                to the repo's root before starts the compile process

        -d <DIR> , --dir <DIR>  Choose the base root of the repo and move to it before compile
                                the source code, if this options is used with -c/--clone flag
                                it will clone the repo in the desire <DIR>

        -p, --python            Install Neovim's python package for python2 and python3

        -r, --ruby              Install Neovim's ruby package

        -f, --force             Ignore errors and warnings and force compilation

        --dev                   Use development builds/portables instead of stable

        --stable                Use stable builds/portables instead of stable

        -C                      Set the compiler, gcc/clang

        -v, --verbose           Enable debug messages

        -h, --help              Display help, if you are seeing this, that means that you already know it (nice)
EOF
    # _show_nvim_help
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

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        error_msg "Internal error in __parse_args function trying to parse $1"
        exit 1
    fi

    local arg="$1"
    local name="$2"

    local pattern="^--${name}=[a-zA-Z0-9.:@_/~-]+$"

    if [[ -n $3 ]]; then
        local pattern="^--${name}=$3$"
    fi

    if [[ $arg =~ $pattern ]]; then
        local left_side="${arg#*=}"
        echo "${left_side/#\~/$HOME}"
    else
        echo "$arg"
    fi
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
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
        --stable)
            DEV=0
            STABLE=1
            ;;
        --dev)
            DEV=1
            STABLE=0
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        *)
            error_msg "Unknown argument $key"
            show_help
            exit 1
            ;;
    esac
    shift
done

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
    if ! git clone --recursive https://github.com/neovim/neovim "${CLONE_LOC:-.}"; then
        error_msg "Failed to clone neovim"
        exit 2
    fi
    pushd "${CLONE_LOC:-neovim}" &>/dev/null || { error_msg "Failed to cd into ${CLONE_LOC:-neovim}" && exit 1; }
fi

status_msg "Cleaning current build"
make clean

BUILD_TYPE="Release"

current_branch="$(git branch --show-current)"
if [[ -z "$current_branch" ]]; then
    current_branch="$(git rev-parse HEAD)"
fi

if [[ $STABLE -eq 1 ]]; then
    BRANCH="${BRANCH:-$(git tag | sort -h | tail -1)}"
elif [[ $DEV -eq 1 ]]; then
    BRANCH="master"
    BUILD_TYPE="RelWithDebInfo"
else
    BRANCH="$current_branch"
fi

if [[ $BRANCH != "$current_branch" ]]; then
    status_msg "Checking out to $BRANCH"
    git checkout "$BRANCH"
fi

status_msg "Building neovim"
verbose_msg "Building $BUILD_TYPE on $BRANCH"
if make CMAKE_BUILD_TYPE="$BUILD_TYPE" -j; then
    INSTALL_DIR="${INSTALL_DIR:-$HOME/.local}"
    status_msg "Installing neovim into $INSTALL_DIR"
    if ! make  CMAKE_BUILD_TYPE="$BUILD_TYPE" CMAKE_INSTALL_PREFIX="$INSTALL_DIR" install; then
        error_msg "Failed to install neovim"
    fi
else
    error_msg "Failed to compile neovim"
fi

if [[ $CLONE -eq 1 ]]; then
    popd >/dev/null  || exit 1
fi

if [[ $ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0
