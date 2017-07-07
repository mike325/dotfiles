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

NAME="$0"
NAME="${NAME##*/}"

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
    echo ""

    __show_nvim_help
}

__LOCATION="$(pwd)"
__URL="https://github.com/neovim/neovim"
__PYTHON_LIBS=0
__RUBY_LIBS=0
__BUILD_LIBS=0
__CLONE=0

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

if [[ "$__CLONE" -eq 1 ]]; then
    __LOCATION="$__LOCATION/neovim"

    git clone --recursive "$__URL" "$__LOCATION"

    if [[ $? -ne 0 ]]; then
        exit 1
    fi
fi

if [[ -d "$__LOCATION" ]]; then
    pushd "$__LOCATION" > /dev/null
else
    exit 1
fi

# Remove all unstaged changes
git checkout . 2>/dev/null

# No a Git repo
if [[ $? -ne 0 ]]; then
    popd > /dev/null && exit 1
fi

# Remove all untracked files
git clean -xdf . 2>/dev/null
rm -fr build/

# Checkout to the stable branch
git checkout v0.2.0 2>/dev/null

if [[ "$__BUILD_LIBS" -eq 1 ]]; then
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
        echo "    ---- [X] Error your system is neither a Debian derivate nor a"
        echo "             Fedora or Arch derivate, please check your system's"
        echo "             dependencies in Neovim's page:"
        echo "             https://github.com/neovim/neovim/wiki/Building-Neovim"
        echo ""
    fi
fi



# Always clean the build dir
make clean

# Prefix the current dir
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$(pwd)"

# make CMAKE_BUILD_TYPE=RelWithDebInfo
# Set the type release to avoid debug messages
make CMAKE_BUILD_TYPE=Release

# Continue only if there isn't errors
if [[ $? -eq 0 ]]; then

    make install

    if [[ $? -eq 0 ]]; then
        export PATH="$(pwd)/bin:$PATH"

        echo ""
        # echo "You may want to add 'export PATH=\"$(pwd)/bin:\$PATH\"' in your ~/.${SHELL##*/}rc"
        echo ""

        if [[ $__PYTHON_LIBS -eq 1 ]]; then
            hash pip2 2> /dev/null && pip2 install --user neovim -y
            hash pip3 2> /dev/null && pip3 install --user neovim -y
        fi

        if [[ $__RUBY_LIBS -eq 1 ]]; then
            hash gem 2> /dev/null && gem install --user-install -y neovim
        fi

        if [[ $__PYTHON_LIBS -eq 0 ]] || [[ $__RUBY_LIBS -eq 0 ]]; then
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
