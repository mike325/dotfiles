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

__NAME="$0"
__NAME="${__NAME##*/}"
__LOCATION="$(pwd)"
__URL="https://github.com/neovim/neovim"
__PYTHON_LIBS=0
__RUBY_LIBS=0
__BUILD_LIBS=0
__CLONE=0


# Warning ! This script delete everything in the work directory before install
function __show_nvim_libs() {
    echo "Please also consider to install the python libs"
    echo "  $ pip3 install --user neovim && pip2 install --user neovim"
    echo "and Ruby libs"
    echo "  $ gem install --user-install neovim"
    echo ""
}

function __show_nvim_help() {
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

    __show_nvim_libs

    echo "For other Unix systems (BSD, Linux and MacOS) and Windows please check"
    echo "  https://github.com/neovim/neovim/wiki/Building-Neovim"
}

function show_help() {
    echo ""
    echo "  Simple script to build and install Neovim directly from the source"
    echo "  with some pretty basic options."
    echo ""
    echo "  Usage:"
    echo "      $__NAME [OPTIONS]"
    echo ""
    echo "      Optional Flags"
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
    echo "          -b, --build"
    echo "              Install all dependencies of the before build neovim's source code"
    echo "              Just few systems are supported, Debian's family, Fedora's family and"
    echo "              ArchLinux's family"
    echo ""
    echo "          -h, --help"
    echo "              Display help, if you are seeing this, that means that you already know it (nice)"
    echo ""

    # __show_nvim_help
}

function warn_msg() {
    WARN_MESSAGE="$1"
    printf "[!]     ---- Warning!!! %s \n" "$WARN_MESSAGE"
}

function error_msg() {
    ERROR_MESSAGE="$1"
    printf "[X]     ---- Error!!!   %s \n" "$ERROR_MESSAGE" 1>&2
}

function status_msg() {
    STATUS_MESSAGGE="$1"
    printf "[*]     ---- %s \n" "$STATUS_MESSAGGE"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -c|--clone)
            __CLONE=1
            ;;
        -d|--dir)
            __LOCATION="$2"
            shift
            ;;
        -p|--python)
            __PYTHON_LIBS=1
            ;;
        -r|--ruby)
            __RUBY_LIBS=1
            ;;
        -b|--build)
            __BUILD_LIBS=1
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
    esac
    shift
done

# Windows stuff
if [[ $(uname --all) =~ MINGW ]]; then
    __IS_WINDOWS=1
    warn_msg "Mingw platform is currently unsupported"
    error_msg "Please follow the official instructions to get Neovim in windows https://github.com/neovim/neovim/wiki/Installing-Neovim#windows"
    exit 1
fi

if [[ "$__CLONE" -eq 1 ]]; then
    __LOCATION="$__LOCATION/neovim"

    git clone --recursive "$__URL" "$__LOCATION" || exit 1
fi

if [[ -d "$__LOCATION" ]]; then
    pushd "$__LOCATION" > /dev/null
else
    error_msg "$__LOCATION doesn't exist"
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

if [[ "$__BUILD_LIBS" -eq 1 ]]; then
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

        if [[ $__PYTHON_LIBS -eq 1 ]]; then
            status_msg "Installing python2 libs"
            hash pip2 2> /dev/null && /usr/bin/yes | pip2 install --user neovim
            status_msg "Installing python3 libs"
            hash pip3 2> /dev/null && /usr/bin/yes | pip3 install --user neovim
        fi

        if [[ $__RUBY_LIBS -eq 1 ]]; then
            status_msg "Installing ruby libs"
            hash gem 2> /dev/null && gem install --user-install neovim
        fi

        if [[ $__PYTHON_LIBS -eq 1 ]] || [[ $__RUBY_LIBS -eq 1 ]]; then
            __show_nvim_libs
        fi

    else
        __show_nvim_help
        popd > /dev/null && exit 1
    fi
else
    __show_nvim_help
    popd > /dev/null && exit 1
fi

popd > /dev/null

exit 0
