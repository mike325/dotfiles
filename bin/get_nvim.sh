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

# colors
black="\033[0;30m"
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
purple="\033[0;35m"
cyan="\033[0;36m"
white="\033[0;37;1m"
orange="\033[0;91m"
normal="\033[0m"
reset_color="\033[39m"

_TMP='/tmp/'

if [ -z "$SHELL_PLATFORM" ]; then
    SHELL_PLATFORM='UNKNOWN'
    case "$OSTYPE" in
      *'linux'*   ) SHELL_PLATFORM='LINUX' ;;
      *'darwin'*  ) SHELL_PLATFORM='OSX' ;;
      *'freebsd'* ) SHELL_PLATFORM='BSD' ;;
      *'cygwin'*  ) SHELL_PLATFORM='CYGWIN' ;;
      *'msys'*    ) SHELL_PLATFORM='MSYS' ;;
    esac
fi


# Warning ! This script delete everything in the work directory before install
function _show_nvim_libs() {
    echo "Please also consider to install the python libs"
    echo "  $ pip3 install --user neovim && pip2 install --user neovim"
    echo "and Ruby libs"
    echo "  $ gem install --user-install neovim"
    echo ""
}

function _show_nvim_help() {
    # echo "    ---- [X] Error Please make sure you have all the dependencies in your system"
    echo ""
    echo "Ubuntu/Debian/Linux mint"
    echo "  # apt-get install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip"
    echo ""
    echo "CentOS/RetHat/Fedora"
    echo "  # dnf install libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip"
    echo ""
    echo "ArchLinux/Antergos/Manjaro"
    echo "  # pacman -S base-devel cmake unzip"
    echo ""

    _show_nvim_libs

    echo "For other Unix systems (BSD, Linux and MacOS) and Windows please check"
    echo "  https://github.com/neovim/neovim/wiki/Building-Neovim"
}

function show_help() {
    echo ""
    echo "  Simple script to build and install Neovim directly from the source"
    echo "  with some pretty basic options."
    echo ""
    echo "  Usage:"
    echo "      $_NAME [OPTIONS]"
    echo ""
    echo "      Optional Flags"
    echo "          --version"
    echo "              Neovim version to download or compile, default, latest"
    echo ""
    echo "          --portable"
    echo "              Download the portable version and place it in $HOME/.local/bin"
    echo ""
    echo "          -c, --clone"
    echo "              By default this script expect to run under a git directory with"
    echo "              the Neovim's source code, this options clone Neovim's repo and move"
    echo "              to the repo's root before starts the compile process"
    echo ""
    echo "          -d <DIR> , --dir <DIR>"
    echo "              Choose the base root of the repo and move to it before compile"
    echo "              the source code, if this options is used with -c/--clone flag"
    echo "              it will clone the repo in the desire <DIR>"
    echo ""
    echo "          -p, --python"
    echo "              Install Neovim's python package for python2 and python3"
    echo ""
    echo "          -r, --ruby"
    echo "              Install Neovim's ruby package"
    echo ""
    echo "          -f, --force"
    echo "              Ignore errors and warnings and force compilation"
    echo ""
    echo "          -b, --build"
    echo "              Install all dependencies of the before build neovim's source code"
    echo "              Just few systems are supported, Debian's family, Fedora's family and"
    echo "              ArchLinux's family"
    echo ""
    echo "          -h, --help"
    echo "              Display help, if you are seeing this, that means that you already know it (nice)"
    echo ""

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
    if ! hash curl 2>/dev/null && ! hash wget 2>/dev/null; then
        error_msg 'Must have curl or wget to download the latest portable'
        exit 1
    fi

    # wget -qO- $URL
    # wget $URL -O out

    local dir="$HOME/.local/bin"

    [[ ! -d "$dir" ]] && mkdir -p "$dir"

    if hash curl 2>/dev/null; then
        local version="$( curl -sL "${_URL}/tags" | grep -oE 'v[0-9]\.[0-9]\.[0-9]$' | sort -u | tail -n 1)"
    else
        local version="$( wget -qO- "${_URL}/tags" | grep -oE 'v[0-9]\.[0-9]\.[0-9]$' | sort -u | tail -n 1)"
    fi

    status_msg "Downloading version: ${version}"
    if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then
        local name="nvim.zip"
        if hash curl 2>/dev/null; then
            curl -sL "$_URL/releases/download/${version}/nvim-win64.zip" -o "$_TMP/$name"
        else
            wget -qL "$_URL/releases/download/${version}/nvim-win64.zip" -o "$_TMP/$name"
        fi
        unzip -qo "$_TMP/$name" && mv "$_TMP/Neovim/*" "$HOME/.local/"
    else
        local name="nvim"
        if hash curl 2>/dev/null; then
            curl -sL "$_URL/releases/download/${version}/nvim.appimage" -o "$_TMP/$name"
        else
            wget -qL "$_URL/releases/download/${version}/nvim.appimage" -o "$_TMP/$name"
        fi
        chmod u+x "$_TMP/$name" && mv "$_TMP/$name" "$dir/$name"
    fi

    return 0
}

function get_libs() {
    if [[ $_PYTHON_LIBS -eq 1 ]]; then
        hash pip2 2> /dev/null && { status_msg "Installing python2 libs" && pip2 install --user neovim; }
        hash pip3 2> /dev/null && { status_msg "Installing python3 libs" && pip3 install --user neovim; }
    fi

    if [[ $_RUBY_LIBS -eq 1 ]]; then
        hash gem 2> /dev/null && { status_msg "Installing ruby libs" && gem install --user-install neovim; }
    fi
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --nocolor)
            _NOCOLOR=1
            ;;
        --portable)
            _PORTABLE=1
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
        -h|--help)
            show_help
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

if [[ $_PORTABLE -eq 1 ]]; then
    get_portable
    get_libs
    exit 0
fi

# Windows stuff
if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then
    warn_msg "Mingw platform is currently unsupported"
    error_msg "Please follow the official instructions to get Neovim in windows https://github.com/neovim/neovim/wiki/Installing-Neovim#windows"
    exit 1
fi

if [[ "$_CLONE" -eq 1 ]] && [[ ! -d "$_LOCATION/neovim" ]]; then
    _LOCATION="$_LOCATION/neovim"
    git clone --recursive "$_URL" "$_LOCATION" || exit 1

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
    pushd "$_LOCATION" > /dev/null || "$( error_msg "Could not get to $_LOCATION" && exit 1)"
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
        echo ""
        echo "    ---- [X] Error your system is not supported to preinstall deps"
        echo "             Supported systems are:"
        echo "                  - Debian family"
        echo "                  - Ubuntu family"
        echo "                  - Archlinux, Antergos and Manjaro"
        echo "                  - Fedora"
        echo "             Please check the ependencies in Neovim's page:"
        echo "             https://github.com/neovim/neovim/wiki/Building-Neovim"
        echo ""
        exit 1
    fi
fi

# BUG: Since the latest stable version (v0.2.0 up to Jul/2017) have "old" deps
# GCC7 works just for the master branch
GCC_VERSION="$(gcc --version | head -1 | awk '{print $3}')"
GCC_VERSION="${GCC_VERSION%%.*}"
# Checkout to the latest stable version
if (( GCC_VERSION < 7 )); then
    status_msg "Using latest stable version $( git tag | tail -n 1 )"
    git checkout "$( git tag | tail -n 1 )" 2>/dev/null
else
    warn_msg "GCC version is > 7, using master to compile source code"
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
