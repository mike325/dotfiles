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
BUILD_LIBS=0
CLONE=0
FORCE_INSTALL=0
PORTABLE=0
VERBOSE=0
DEV=0
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

if ! hash is_wsl 2>/dev/null; then
    function is_wsl() {
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

# Warning ! This script delete everything in the work directory before install
function _show_nvim_libs() {
    cat <<EOF
Please also consider to install the python libs
    $ pip3 install --upgrade --user pynvim && pip2 install --upgrade --user pynvim
and Ruby libs
    $ gem install --user-install neovim
EOF
}

function _show_nvim_help() {
    cat <<EOF
Ubuntu/Debian/Linux mint
    # apt-get install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip

CentOS/RetHat/Fedora
    # dnf install libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip

ArchLinux/Antergos/Manjaro
    # pacman -S base-devel cmake unzip
EOF

    _show_nvim_libs

    cat <<EOF
For other Unix systems (BSD, Linux and MacOS) and Windows please check
    https://github.com/neovim/neovim/wiki/Building-Neovim
EOF
}

function show_help() {
    cat <<EOF
Simple script to build and install Neovim directly from the source
with some pretty basic options.

Usage:
    $NAME [OPTIONS]

    Optional Flags
        --portable
            Download the portable version and place it in $HOME/.local/bin

        -c, --clone
            By default this script expect to run under a git directory with
            the Neovim's source code, this options clone Neovim's repo and move
            to the repo's root before starts the compile process

        -d <DIR> , --dir <DIR>
            Choose the base root of the repo and move to it before compile
            the source code, if this options is used with -c/--clone flag
            it will clone the repo in the desire <DIR>

        -p, --python
            Install Neovim's python package for python2 and python3

        -r, --ruby
            Install Neovim's ruby package

        -f, --force
            Ignore errors and warnings and force compilation

        -b, --build
            Install all dependencies of the before build neovim's source code
            Just few systems are supported, Debian's family, Fedora's family and
            ArchLinux's family

        --dev
            Use developement builds/portables instead of stable

        -v, --verbose
            Enable debug messages

        -h, --help
            Display help, if you are seeing this, that means that you already know it (nice)
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

    # wget -qO- $URL
    # wget $URL -O out

    local dir="$HOME/.local/bin"
    local cmd=''
    local version
    local build

    if hash curl 2>/dev/null; then
        local cmd='curl -L'
        [[ $VERBOSE -eq 0 ]] && local cmd="${cmd} -s"
    else
        local cmd='wget -q0-'
    fi

    verbose_msg "Using ${cmd} as command"

    [[ ! -d $dir ]] && mkdir -p "$dir"

    if [[ $DEV -eq 0 ]] && [[ $NVIM_VERSION == 'latest' ]]; then
        version=$( eval "${cmd} ${URL}/tags/ | grep -oE 'v[0-9]\.[0-9]\.[0-9]+' | sort -u | tail -n 1")
        status_msg "Downloading version: ${version}"
    elif [[ $DEV -eq 1 ]]; then
        status_msg "Downloading Nightly"
    else
        status_msg "Downloading ${NVIM_VERSION}"
    fi

    if is_windows; then
        local name="nvim.zip"
        local pkg='nvim-win64.zip'
    elif is_osx; then
        local name="nvim.tar.gz"
        local pkg='nvim-macos.tar.gz'
    else
        local name="nvim"
        local pkg='nvim.appimage'
    fi

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

    if is_windows; then
        verbose_msg "Unpacking ${name}"
        if ! unzip -qo "$TMP/$name" -d "$HOME/AppData/Roaming/"; then
            return 1
        fi
        rm -rf "${TMP:?}/${name}"
    elif is_osx; then
        pushd "$TMP" >/dev/null  || { error_msg "Could not get to $TMP" && exit 1; }
        verbose_msg "Unpacking ${name}"
        if ! tar xzvf "$TMP/$name" && mv "${TMP}/nvim-osx64/*" "$HOME/.local/"; then
            return 1
        fi
        popd >/dev/null  || { error_msg "Could not get out of $TMP" && exit 1; }
        rm -rf "${TMP:?}/${name}"
        rm -rf "${TMP:?}/nvim-osx64"
    else
        verbose_msg "Installing into $dir/$name"
        chmod u+x "$TMP/$name" && mv "$TMP/$name" "$dir/$name"
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
        -b | --build)
            BUILD_LIBS=1
            ;;
        -v | --verbose)
            VERBOSE=1
            ;;
        --dev)
            DEV=1
            BRANCH="master"
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
    return 1
fi

if [[ $CLONE -eq 1 ]]; then
    status_msg "Cloning neovim repo"
    if ! git clone --recursive https://github.com/neovim/neovim "${CLONE_LOC:.}"; then
        error_msg "Failed to clone neovim"
        exit 2
    fi
    pushd "${CLONE_LOC:-neovim}" &>/dev/null || { error_msg "Failed to cd into ${CLONE_LOC:-neovim}" && exit 1; }
fi

if [[ $BUILD_LIBS -eq 1   ]]; then
    status_msg "Looking for system dependencies"
    if hash apt-get 2>/dev/null; then
        sudo apt-get install -y \
            libtool \
            libtool-bin \
            autoconf \
            automake \
            pkg-config \
            gcc \
            g++ \
            lldb-11 \
            clang-11 \
            clang-tools-11 \
            clangd-11 \
            clang-tidy-11 \
            make \
            cmake \
            unzip
            # build-essential
            # python-dev
            # python3-dev
            # ruby-dev
    elif hash dnf 2>/dev/null; then
        sudo dnf -y install \
            libtool \
            autoconf \
            automake \
            cmake \
            gcc \
            gcc-c++ \
            make \
            pkgconfig \
            unzip
            # python-dev
            # python2-dev
            # ruby-dev
    elif hash pacman 2>/dev/null; then
        sudo pacman -S --noconfirm \
            base-devel \
            clang \
            clangd \
            lldb \
            llvm \
            make \
            cmake \
            unzip
            # python-dev
            # python2-dev
            # ruby-dev
    else
        cat <<EOF
    ---- [X] Error your system is not supported to preinstall deps
             Supported systems are:
                  - Debian family
                  - Ubuntu family
                  - Archlinux, Antergos and Manjaro
                  - Fedora
             Please check the ependencies in Neovim's page:
             https://github.com/neovim/neovim/wiki/Building-Neovim
EOF
        exit 1
    fi
fi

# Always clean the build dir
status_msg "Cleaning repo"
# Remove all untracked files
git clean -df . 2>/dev/null
make clean
# make distclean

# Get latest version
status_msg "Pulling latest changes"
git checkout master
git pull origin master
status_msg "Checking out to ${BRANCH:-$(git tag | sort -h | tail -1)}"
git checkout "${BRANCH:-$(git tag | sort -h | tail -1)}"

status_msg "Building neovim"
if make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="${INSTALL_DIR:-$HOME/.local}"; then
    status_msg "Installing neovim into ${INSTALL_DIR:-$HOME/.local}"
    if make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="${INSTALL_DIR:-$HOME/.local}" install; then
        get_libs
    else
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
