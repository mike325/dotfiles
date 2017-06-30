#!/usr/bin/env bash

#   Author: Mike 8a
#   Description: Install all my basic configs and scripts
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
#            .`   github.com/mike325/dotfiles   `/

_ALL=1
_ALIAS=0
_VIM=0
_NVIM=0
_BIN=0
_SHELL_FRAMEWORK=0
_EMACS=0
_DOTFILES=0
_GIT=0

_NAME="$0"
_NAME="${_NAME##*/}"

_SCRIPT_PATH="$0"
_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

_CMD="ln -s"

function help_user() {
    echo ""
    echo "  Simple installer of this dotfiles"
    echo ""
    echo "  Usage:"
    echo "      $_NAME [OPTIONAL]"
    echo ""
    echo "      Optional Flags"
    echo "          -h, --help"
    echo "              Display help, if you are seeing this, that means that you already know it (nice)"
    echo ""
}

function setup_scripts() {
    for script in ${_SCRIPT_PATH}/bin/*; do
        local file_basename="${script%.*}"
        local file_extention="${script#*.}"

        sh -c "$_CMD $script $HOME/.local/bin/$file_basename"
    done

    sh -c "$_CMD ${_SCRIPT_PATH}/scripts/pythonstartup.py $HOME/.local/lib/pythonstartup.py"

    sh -c "$_CMD ${_SCRIPT_PATH}/ctags $HOME/.ctags"
}

function setup_alias() {
    sh -c "$_CMD ${_SCRIPT_PATH}/alias $HOME/.alias"

    # Currently just ZSH and BASH are the available shells
    if [[ -f "${_SCRIPT_PATH}/shell/${SHELL}rc" ]]; then
        sh -c "$_CMD ${_SCRIPT_PATH}/shell/${SHELL}rc $HOME/.${SHELL}rc"
    fi
}

function setup_git() {
    sh -c "$_CMD ${_SCRIPT_PATH}/gitconfig $HOME/.gitconfig"
    sh -c "$_CMD ${_SCRIPT_PATH}/git_template $HOME/.git_template"
}

function get_vim_dotfiles() {
    git clone --recursive https://github.com/mike325/.vim "$HOME/.vim"
    sh -c "$_CMD $HOME/.vim/init.vim $HOME/.vimrc"
}

function get_nvim_dotfiles() {
    # Since no all systems have sudo/root access lets assume all dependencies are
    # already installed; Lets clone neovim in $HOME/.local/neovim and install pip libs
    ${_SCRIPT_PATH}/bin/get_nvim.sh -c -d "$HOME/.local/" -p

    # if the current command creates a symbolic link and we already have some vim
    # settings, lets use them
    if [[ "$_CMD" == "ln -s" ]] && [[ -d "$HOME/.vim" ]]; then
        sh -c "$_CMD $HOME/.vim $HOME/.config/nvim"
    else
        # else lets clone my vim dotfiles
        git clone --recursive https://github.com/mike325/.vim "$HOME/.config/nvim"
    fi
}

function get_emacs_dotfiles() {
    git clone --recursive https://github.com/mike325/.emacs.d "$HOME/.emacs.d"

    mkdir -p "$HOME/.config/systemd/user"
    sh -c "$_CMD ${_SCRIPT_PATH}/services/emacs.service $HOME/.config/systemd/user/emacs.service"
}

function setup_shell_framework() {
    ${_SCRIPT_PATH}/bin/get_shell.sh
}

function get_dotfiles() {
    mkdir -p "$HOME/.local/"
    _SCRIPT_PATH="$HOME/.local/dotfiles"
    git clone --recursive https://github.com/mike325/dotfiles "$_SCRIPT_PATH"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -c|--copy)
            _CMD="cp -rf"
            ;;
        -a|--alias)
            _ALIAS=1
            _ALL=0
            ;;
        -f|--frameworks)
            _SHELL_FRAMEWORK=1
            _ALL=0
            ;;
        -d|--dotfiles)
            _DOTFILES=1
            ;;
        -e|--emacs)
            _EMACS=1
            _ALL=0
            ;;
        -v|--vim)
            _VIM=1
            _ALL=0
            ;;
        -n|--neovim)
            _NVIM=1
            _ALL=0
            ;;
        -b|--bin)
            _BIN=1
            _ALL=0
            ;;
        -g|--git)
            _GIT=1
            _ALL=0
            ;;
        -h|--help)
            help_user
            exit 0
            ;;
    esac
    shift
done

[[ -d "$HOME/.local/bin" ]] && mkdir -p "$HOME/.local/bin"
[[ -d "$HOME/.local/lib" ]] && mkdir -p  "$HOME/.local/lib/"

# If the user request the dotfiles or the script path doesn't have the full files
# (the command may be executed using `curl`)
if [[ $_DOTFILES -eq 1 ]] || [[ ! -f "${_SCRIPT_PATH}/bin/get_nvim.sh" ]]; then
    get_dotfiles
fi

if [[ $_ALL -eq 1 ]]; then
    setup_scripts
    setup_alias
    setup_shell_framework
    setup_git
    get_vim_dotfiles
    get_nvim_dotfiles
    get_emacs_dotfiles
else
    [[ $_BIN -eq 1 ]] && setup_scripts
    [[ $_ALIAS -eq 1 ]] && setup_alias
    [[ $_SHELL_FRAMEWORK -eq 1 ]] && setup_shell_framework
    [[ $_GIT -eq 1 ]] && setup_git
    [[ $_VIM -eq 1 ]] && get_vim_dotfiles
    [[ $_NVIM -eq 1 ]] && get_nvim_dotfiles
    [[ $_EMACS -eq 1 ]] && get_emacs_dotfiles
fi
