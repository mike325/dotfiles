#!/usr/bin/env bash

#   Author: Mike 8a
#   Description: Kind of unnecessary complicated script that attempts to
#                install the necessary dependencies, get and build Neovim
#                from the Git repo (github) and get the python and/or ruby libs
#
#   Usage:
#       $ get_nvim              # Leave all defaults,
#                               # - Doesn't clone (assume the repo is already cloned)
#                               # - Doesn't get libs or build deps,
#                               # - Installation dir is the current dir
#       $ get_nvim -d stuff_dir # Change the installation dir
#       $ get_nvim -c           # Clone the repo, leave everything else by default
#       $ get_nvim -p -r        # Get the python (-p) and ruby (-r) libs after install
#       $ get_nvim -b           # Get the build dependencies on some systems
#       $ get_nvim -h           # Show help, kind of
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

_NAME="$0"
_NAME="${_NAME##*/}"
_LOCATION="$(pwd)"
_URL="https://github.com/neovim/neovim"
_PYTHON_LIBS=0
_RUBY_LIBS=0
_BUILD_LIBS=0
_CLONE=0
_FORCE_INSTALL=0
_PORTABLE=0
_NOCOLOR=0
_VERBOSE=0
_DEV=0

_NVIM_VERSION="latest"

_OS='unknown'

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

_TMP='/tmp/'

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


case "$SHELL_PLATFORM" in
    # TODO: support more linux distros
    linux)
        if [[ -f /etc/arch-release ]]; then
            _OS='arch'
        elif [[ "$(cat /etc/issue)" == Ubuntu* ]]; then
            _OS='ubuntu'
        elif [[ -f /etc/debian_version ]]; then
            if [[ "$(uname -a)" == *\ armv7* ]]; then # Raspberry pi 3 uses armv7 cpu
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

# _ARCH="$(uname -m)"

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

# Warning ! This script delete everything in the work directory before install
function _show_nvim_libs() {
    cat << EOF
Please also consider to install the python libs
    $ pip3 install --upgrade --user pynvim && pip2 install --upgrade --user pynvim
and Ruby libs
    $ gem install --user-install neovim
EOF
}

function _show_nvim_help() {
    cat << EOF
Ubuntu/Debian/Linux mint
    # apt-get install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip

CentOS/RetHat/Fedora
    # dnf install libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip

ArchLinux/Antergos/Manjaro
    # pacman -S base-devel cmake unzip
EOF

    _show_nvim_libs

    cat << EOF
For other Unix systems (BSD, Linux and MacOS) and Windows please check
    https://github.com/neovim/neovim/wiki/Building-Neovim
EOF
}

function show_help() {
    cat << EOF
Simple script to build and install Neovim directly from the source
with some pretty basic options.

Usage:
    $_NAME [OPTIONS]

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
    local warn_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s \n" "$warn_message"
    else
        printf "[!] Warning:\t %s \n" "$warn_message"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s \n" "$error_message" 1>&2
    else
        printf "[X] Error:\t %s \n" "$error_message" 1>&2
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s \n" "$status_message"
    else
        printf "[*] Info:\t %s \n" "$status_message"
    fi
    return 0
}

function verbose_msg() {
    if [[ $_VERBOSE -eq 1 ]]; then
        local debug_message="$1"
        if [[ $_NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s \n" "$debug_message"
        else
            printf "[+] Debug:\t %s \n" "$debug_message"
        fi
    fi
    return 0
}

function get_portable() {
    if [[ $_OS == 'raspbian' ]]; then
        error_msg "There's no neovim portable version for ARM devices"
        return 1
    fi

    if ! hash curl 2>/dev/null && ! hash wget 2>/dev/null; then
        error_msg 'Must have curl or wget to download the latest portable'
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
        [[ $_VERBOSE -eq 0 ]] && local cmd="${cmd} -s"
    else
        local cmd='wget -q0-'
    fi

    verbose_msg "Using ${cmd} as command"

    [[ ! -d "$dir" ]] && mkdir -p "$dir"

    if [[ $_DEV -eq 0 ]] && [[ $_NVIM_VERSION == 'latest' ]]; then
        version=$( eval "${cmd} ${_URL}/tags/ | grep -oE 'v[0-9]\.[0-9]\.[0-9]+' | sort -u | tail -n 1")
        status_msg "Downloading version: ${version}"
    elif [[ $_DEV -eq 1 ]]; then
        status_msg "Downloading Nightly"
    else
        status_msg "Downloading ${_NVIM_VERSION}"
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

    if [[ $_DEV -eq 1 ]]; then
        build='nightly'
    elif [[ $_NVIM_VERSION == 'latest' ]]; then
        build='stable'
    else
        build="v${_NVIM_VERSION}"
    fi

    verbose_msg "Downloading ${pkg} from $_URL/releases/download/${build}/${pkg} to $_TMP/$name"

    if ! eval '${cmd} "$_URL/releases/download/${build}/${pkg}" -o "$_TMP/$name"'; then
        error_msg "Fail to download neovim"
        return 1
    fi

    if is_windows; then
        verbose_msg "Unpacking ${name}"
        if ! unzip -qo "$_TMP/$name" -d "$HOME/AppData/Roaming/"; then
            return 1
        fi
        rm -rf "${_TMP:?}/${name}"
    elif is_osx; then
        pushd "$_TMP" > /dev/null || { error_msg "Could not get to $_TMP" && exit 1; }
        if ! tar xzvf "$_TMP/$name" && mv "${_TMP}/nvim-osx64/*" "$HOME/.local/"; then
            return 1
        fi
        popd > /dev/null || { error_msg "Could not get out of $_TMP" && exit 1; }
        rm -rf "${_TMP:?}/${name}"
        rm -rf "${_TMP:?}/nvim-osx64"
    else
        chmod u+x "$_TMP/$name" && mv "$_TMP/$name" "$dir/$name"
    fi

    return 0
}

function get_libs() {
    if [[ $_PYTHON_LIBS -eq 1 ]]; then
        hash pip2 2> /dev/null && { status_msg "Installing python2 libs" && pip2 install --upgrade --user pynvim; }
        hash pip3 2> /dev/null && { status_msg "Installing python3 libs" && pip3 install --upgrade --user pynvim; }
    fi

    if [[ $_RUBY_LIBS -eq 1 ]]; then
        hash gem 2> /dev/null && { status_msg "Installing ruby libs" && gem install --user-install neovim; }
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

    if [[ -n "$3" ]]; then
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
            _NOCOLOR=1
            ;;
        --portable=*)
            _PORTABLE=1
            _result=$(__parse_args "$key" "portable" '[0-9]\.[0-9](\.[0-9])?')
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid version ${_result##*=}"
                exit 1
            fi
            _NVIM_VERSION="$_result"
            ;;
        --portable)
            _PORTABLE=1
            if [[ "$2" =~ ^[0-9]\.[0-9](\.[0-9])?$ ]]; then
                _NVIM_VERSION="$2"
                shift
            fi
            ;;
        -f|--force)
            _FORCE_INSTALL=1
            ;;
        -c|--clone)
            _CLONE=1
            ;;
        -d|--dir)
            _LOCATION="$2"
            shift
            ;;
        -p|--python)
            _PYTHON_LIBS=1
            ;;
        -r|--ruby)
            _RUBY_LIBS=1
            ;;
        -b|--build)
            _BUILD_LIBS=1
            ;;
        -v|--verbose)
            _VERBOSE=1
            ;;
        --dev)
            _DEV=1
            ;;
        -h|--help)
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

if [[ $_PORTABLE -eq 1 ]]; then
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

if [[ "$_CLONE" -eq 1 ]] && [[ ! -d "$_LOCATION/neovim" ]]; then
    _LOCATION="$_LOCATION/neovim"
    git clone --quiet --recursive "$_URL" "$_LOCATION" || exit 1

elif [[ -d "$_LOCATION/neovim" ]]; then
    warn_msg "$_LOCATION/neovim already exists, skipping cloning"
    _LOCATION="$_LOCATION/neovim"
fi

if [[ -f "$_LOCATION/bin/nvim" ]] && [[ $_FORCE_INSTALL -eq 0 ]]; then
    status_msg "Neovim is already compiled, aborting"
    exit 0
elif [[ $_FORCE_INSTALL -eq 1 ]]; then
    warn_msg "Neovim is already compiled, but fuck it, you want to recompile"
fi


if [[ -d "$_LOCATION" ]]; then
    pushd "$_LOCATION" > /dev/null || { error_msg "Could not get to $_LOCATION" && exit 1; }
else
    error_msg "$_LOCATION doesn't exist"
    exit 1
fi

# Remove all unstaged changes
if ! git checkout . 2>/dev/null; then
    # No a Git repo
    error_msg "The current dir $(pwd -P) is not a Neovim git repo"
    popd > /dev/null && exit 1
fi

# Remove all untracked files
git clean -xdf . 2>/dev/null
rm -fr build/

# Get latest version
git checkout master
git pull origin master

if [[ "$_BUILD_LIBS" -eq 1 ]]; then
    status_msg "Looking for system dependencies"

    if hash apt-get 2> /dev/null; then
        sudo apt-get install -y \
            libtool \
            libtool-bin \
            autoconf \
            automake \
            cmake \
            g++ \
            pkg-config \
            unzip
            # build-essential
            # python-dev
            # python3-dev
            # ruby-dev
    elif hash dnf 2> /dev/null; then
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
    elif hash yaourt 2> /dev/null; then
        yaourt -S --noconfirm \
            base-devel \
            cmake \
            unzip
            # python-dev
            # python2-dev
            # ruby-dev
    elif hash pacman 2> /dev/null; then
        sudo pacman -S --noconfirm \
            base-devel \
            cmake \
            unzip
            # python-dev
            # python2-dev
            # ruby-dev
    else
        cat << EOF
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

# BUG: Since the latest stable version (v0.2.0 up to Jul/2017) have "old" deps
# GCC7 works just for the master branch
GCC_VERSION="$(gcc --version | head -1 | awk '{print $3}')"
GCC_VERSION="${GCC_VERSION%%.*}"
# Checkout to the latest stable version
if (( GCC_VERSION < 7 )) || [[ $_DEV -eq 0 ]]; then
    status_msg "Using latest stable version $( git tag | tail -n 1 )"
    git checkout "$( git tag | tail -n 1 )" 2>/dev/null
elif [[ $_DEV -eq 1 ]]; then
    status_msg "Using master HEAD"
fi

# Always clean the build dir
make clean

# Prefix the current dir
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$(pwd)"

# make CMAKE_BUILD_TYPE=RelWithDebInfo
# Set the type release to avoid debug messages
# Continue only if there isn't errors
if make CMAKE_BUILD_TYPE=Release; then

    if make install; then
        # export PATH="$(pwd)/bin:$PATH"

        echo ""
        # echo "You may want to add 'export PATH=\"$(pwd)/bin:\$PATH\"' in your ~/.${SHELL##*/}rc"
        echo ""

        get_libs

    else
        _show_nvim_help
        popd > /dev/null && exit 1
    fi
else
    _show_nvim_help
    popd > /dev/null && exit 1
fi

popd > /dev/null || exit 1

exit 0
