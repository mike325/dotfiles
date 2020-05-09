#!/usr/bin/env bash
# shellcheck disable=SC1117

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
_COOL_FONTS=0
_SHELL=0
_VIM=0
_NVIM=0
_BIN=0
_SHELL_SCRIPTS=0
_SHELL_FRAMEWORK=0
_EMACS=0
_DOTFILES=0
_GIT=0
_FORCE_INSTALL=0
_BACKUP=0
_BACKUP_DIR="$HOME/.local/backup_$(date '+%d.%b.%Y_%H-%M-%S')"
_VERBOSE=0
_PORTABLES=0
_SYSTEMD=0
_NOCOLOR=0
_PYTHON=0
_NOLOG=0
_PKGS=0
_TMP="/tmp/"
_PKG_FILE=""
_NEOVIM_DOTFILES=0

_NEOVIM_DEV=0

_CMD="ln -fns"

_PYTHON_VERSION="all"
_PROTOCOL="https"
_GIT_USER="mike325"
_GIT_HOST="github.com"
_URL=""

# _GIT_SSH=0

_VERSION="0.5.0"

_NAME="$0"
_NAME="${_NAME##*/}"
_LOG="${_NAME%%.*}.log"

_WARN_COUNT=0
_ERR_COUNT=0

_SCRIPT_PATH="$0"

_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

_OS='unknown'

trap '{ exit_append; }' EXIT
trap '{ clean_up; }' SIGTERM SIGINT

if hash realpath 2>/dev/null; then
    _SCRIPT_PATH=$(realpath "$_SCRIPT_PATH")
else
    pushd "$_SCRIPT_PATH" 1> /dev/null || exit 1
    _SCRIPT_PATH="$(pwd -P)"
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

_ARCH="$(uname -m)"

case "$SHELL_PLATFORM" in
    # TODO: support more linux distros
    linux)
        if [[ -f /etc/arch-release ]]; then
            _OS='arch'
        elif [[ "$(cat /etc/issue)" == Ubuntu* ]]; then
            _OS='ubuntu'
        elif [[ -f /etc/debian_version ]] || [[ "$(cat /etc/issue)" == Debian* ]]; then
            if [[ $_ARCH == *\ armv7* ]]; then # Raspberry pi 3 uses armv7 cpu
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

function is_windows() {
    if [[ $SHELL_PLATFORM =~ (msys|cygwin|windows) ]]; then
        return 0
    fi
    return 1
}

function is_wsl() {
    if [[ "$(uname -r)" =~ Microsoft ]] ; then
        return 0
    fi
    return 1
}

function is_osx() {
    if [[ $SHELL_PLATFORM == 'osx' ]]; then
        return 0
    fi
    return 1
}

function has_fetcher() {
    if hash curl 2>/dev/null || hash wget 2>/ddv/null; then
        return 0
    fi
    return 1
}

if [[ -n "$ZSH_NAME" ]]; then
    _CURRENT_SHELL="zsh"
elif [[ -n "$BASH" ]]; then
    _CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    # _CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
    # _CURRENT_SHELL="${_CURRENT_SHELL##*/}"
    # _CURRENT_SHELL="${_CURRENT_SHELL##*:}"
    if [[ -z "$_CURRENT_SHELL" ]]; then
        _CURRENT_SHELL="${SHELL##*/}"
    fi
fi

# TODO: This should work with ARM 64bits
function is_64bits() {
    if [[ $_ARCH == 'x86_64' ]]; then
        return 0
    fi
    return 1
}

if is_windows; then
    # Windows does not support links we will use cp instead
    _CMD="cp -rf"
    USER="$USERNAME"
else
    # Hack when using sudo
    # TODO: Must fix this
    if [[ $_CURRENT_SHELL == "sudo" ]] || [[ $_CURRENT_SHELL == "su" ]]; then
        _CURRENT_SHELL="$(ps | head -4 | tail -n 1 | awk '{ print $4 }')"
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

# TODO:
# 1) Add colors to the script
# 2) Improve Neovim and portables install

function help_user() {
    cat<<EOF

Description
    Simple installer of this dotfiles, by default install (link) all settings and configurations
    if any flag is given, the script will install just want is being told to do.

Usage:
    $_NAME [OPTIONS]

    Optional Flags
        --host
            Change default git host, the new host (ex. gitlab.com) must have the following repos
                - .vim
                - .emacs.d
                - dotfiles

            Default: github.com

        --user
            Change default git user, the new user (ex. mike325) must have the following repos
                - .vim
                - .emacs.d
                - dotfiles

            Default: mike325

        -p, --protocol
            Alternate between different git protocol
                - https (default)
                - ssh
                - git (not tested)

            Default: https

        --url
            Provie full git url (ex. https://gitlab.com/mike325), the new base user must have
            the following repos
                - .vim
                - .emacs.d
                - dotfiles

            Default: https://$_GIT_HOST/$_GIT_USER

        --backup,
            Backup all existing files into $HOME/.local/backup or the provided dir
            ----    Backup will be auto activated if windows is running or '-c/--copy' flag is used

            Default: off in linux on in windows

        -f, --force
            Force installation, remove all previous conflict files before installing
            This flag is always disable by default

            Default: off

        --shell_scripts
            Install some bash/zsh shell scripts like:
                - tmux tpm
                - z.sh
                - screenfetch
            Current shell:   $_CURRENT_SHELL

            Default: on

        -w, --shell_frameworks, --SHELL_PLATFORM=SHELL
            Install shell frameworks, bash-it or oh-my-zsh according to the current shell
            Current shell:   $_CURRENT_SHELL
            If SHELL is given then force install SHELL framework (bash or zsh)

            Default: on

        -c, --copy
            By default all dotfiles are linked using 'ln -s' command, this flag change
            the command to 'cp -rf' this way you can remove the folder after installation
            but you need to re-download the files each time you want to update the files
            ----    Ignored option in Windows platform
            ----    WARNING!!! if you use the option -f/--force all host Setting will be deleted!!!

            Default: off in linux on in windows

        -s, --shell
            Install:
                - Shell alias in $HOME/.config/shell
                - Shell basic configurations \${SHELL}rc for bash, zsh, tcsh and csh
                - Everything inside ./dotconfigs into $HOME
                - Python startup script in $HOME/.local/lib/

            Default: on

        -d, --dotfiles
            Download my dotfiles repo in case, this options is meant to be used in case this
            script is standalone executed
                Default URL: $_PROTOCOL://$_GIT_HOST/$_GIT_USER/dotfiles

            Default: off unless this script is executed from outside of the repo

        -e, --emacs
            Download and install my evil Emacs dotfiles
                Default URL: $_PROTOCOL://$_GIT_HOST/$_GIT_USER/.emacs.d

            Default: on

        -v, --vim
            Download and install my Vim dotfiles
                Default URL: $_PROTOCOL://$_GIT_HOST/$_GIT_USER/.vim

            Default: on

        -n, --nvim, --neovim=[stable|dev]
            Download Neovim executable (portable in windows and linux) if it hasn't been Installed
            Download and install my Vim dotfiles in Neovim's dir.
            Check if vim dotfiles are already install and copy/link (depends of '-c/copy' flag) them,
            otherwise download them from vim's dotfiles repo
                Default URL: $_PROTOCOL://$_GIT_HOST/$_GIT_USER/.vim
            Select the type of neovim version to download using 'stable' or 'dev'

            Default: on

        -b, --bin
            Install shell functions and scripts in $HOME/.local/bin

            Default: on

        -g, --git
            Install git configurations into $HOME/.config/git and $HOME/.gitconfig
            Install:
                - Gitconfigs
                - Hooks
                - Templates

            Default: on

        -t, --portables
            Install isolated/portable programs into $HOME/.local/bin
                - neovim
                - shellcheck
                - texlab
                - fd
                - ripgrep
                - pip2 and pip3
                - fzf (GNU/Linux only)
                - jq (GNU/Linux only)

            Default: on

        --fonts, --powerline
            Install the powerline patched fonts
                * Since the patched fonts have different install method for Windows
                they are just download
                * This options is ignored if the install script is executed in a SSH session

            Default: on

        --python, --python=VERSION
            If no version is given install python2 and python3 dependencies from:
                - ./packages/${_OS}/python2
                - ./packages/${_OS}/python3
            else install packages from the given version (2 or 3)

            Default: on with python2 and python3

        --pkgs, --packages, --packages=PKG_FILE [--only]
            Install all .pkg files from ./packages/${_OS}/
            if the package file is given then force install packages from there
            Additional flag --only cancel all other flags

            Default: off

        -y, systemd
            Install user's systemd services (Just in Linux systems)
                * Services are install in $HOME/.config/systemd/user

            Default: on

        --nolog
            Disable log writting

            Default: off

        --nocolor
            Disable color output

            Default: off

        --verbose
            Output debug messages

            Default: off

        --version
            Display the version and exit

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

function warn_msg() {
    local warn_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$warn_message"
    else
        printf "[!] Warning:\t %s\n" "$warn_message"
    fi
    _WARN_COUNT=$(( _WARN_COUNT + 1 ))
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$warn_message" >> "${_LOG}"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$error_message" 1>&2
    else
        printf "[X] Error:\t %s\n" "$error_message" 1>&2
    fi
    _ERR_COUNT=$(( _ERR_COUNT + 1 ))
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[X] Error:\t\t %s\n" "$error_message" >> "${_LOG}"
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s\n" "$status_message"
    else
        printf "[*] Info:\t %s\n" "$status_message"
    fi
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$status_message" >> "${_LOG}"
    fi
    return 0
}

function verbose_msg() {
    local debug_message="$1"
    if [[ $_VERBOSE -eq 1 ]]; then
        if [[ $_NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$debug_message"
        else
            printf "[+] Debug:\t %s\n" "$debug_message"
        fi
    fi
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$debug_message" >> "${_LOG}"
    fi
    return 0
}

function initlog() {
    if [[ $_NOLOG -eq 0 ]]; then
        rm -f "${_LOG}" 2>/dev/null
        if ! touch "${_LOG}" &>/dev/null; then
            error_msg "Fail to init log file"
            _NOLOG=1
            return 1
        fi
        if [[ -f "${_SCRIPT_PATH}/shell/banner" ]]; then
            cat "${_SCRIPT_PATH}/shell/banner" > "${_LOG}"
        fi
        if ! is_osx; then
            _LOG=$(readlink -e "${_LOG}")
        fi
        verbose_msg "Using log at ${_LOG}"
    fi
    return 0
}


function exit_append() {
    if [[ $_NOLOG -eq 0 ]]; then
        if [[ $_WARN_COUNT -gt 0 ]] || [[ $_ERR_COUNT -gt 0 ]]; then
            printf "\n\n" >> "${_LOG}"
        fi

        if [[ $_WARN_COUNT -gt 0 ]]; then
            printf "[*] Warnings:\t%s\n" "$_WARN_COUNT" >> "${_LOG}"
        fi
        if [[ $_ERR_COUNT -gt 0 ]]; then
            printf "[*] Errors:\t\t%s\n" "$_ERR_COUNT" >> "${_LOG}"
        fi
    fi
    return 0
}

function clean_up() {
    verbose_msg "Cleaning up by interrupt"
    verbose_msg "Cleanning up rg ${_TMP}/rg.*" && rm -rf "${_TMP}/rg.*" 2>/dev/null
    verbose_msg "Cleanning up rg $_TMP/ripgrep-*" && rm -rf "$_TMP/ripgrep-*" 2>/dev/null
    verbose_msg "Cleanning up fd ${_TMP}/fd.*" && rm -rf "${_TMP}/fd.*" 2>/dev/null
    verbose_msg "Cleanning up fd $_TMP/fd-*" && rm -rf "$_TMP/fd-*" 2>/dev/null
    verbose_msg "Cleanning up pip $_TMP/get-pip.py" && rm -rf "$_TMP/get-pip.py" 2>/dev/null
    verbose_msg "Cleanning up shellcheck $_TMP/shellcheck*" && rm -rf "$_TMP/shellcheck*" 2>/dev/null
    verbose_msg "Cleanning up ctags $_TMP/ctags*" && rm -rf "$_TMP/ctags*" 2>/dev/null
    verbose_msg "Cleanning up nvim $_TMP/nvim" && rm -rf "$_TMP/nvim" 2>/dev/null
    exit_append
    exit 1
}

function setup_config() {
    local pre_cmd="$1"
    local post_cmd="$2"

    if [[ $_BACKUP -eq 1 ]]; then
        # We check if the target exist since we could be adding new
        # scripts that may no be installed
        if [[ -f "$post_cmd" ]] || [[ -d "$post_cmd" ]]; then
            local name="${post_cmd##*/}"
            # We want to copy all non symbolic links
            if [[ ! -L "$post_cmd" ]]; then
                verbose_msg "Backing up $post_cmd to ${_BACKUP_DIR}/${name}"
                cp -rf --backup=numbered "$post_cmd" "${_BACKUP_DIR}/${name}"
            elif [[ -d "$post_cmd/host" ]] && [[ $(ls -A "$post_cmd/host") ]]; then
                # Check for host specific settings only if it's not empty
                verbose_msg "Backing up $post_cmd/host to ${_BACKUP_DIR}/${name}/host"
                cp -rf --backup=numbered "$post_cmd/host" "${_BACKUP_DIR}/${name}"
            else
                verbose_msg "Nothing to backup in $post_cmd"
            fi

            rm -rf "$post_cmd"
        fi
    elif [[ $_FORCE_INSTALL -eq 1 ]]; then
        verbose_msg "Removing $post_cmd"
        rm -rf "$post_cmd"
    elif [[ -f "$post_cmd" ]] || [[ -e "$post_cmd" ]] || [[ -d "$post_cmd" ]]; then
        warn_msg "Skipping ${post_cmd##*/}, already exists in ${post_cmd%/*}"
        return 1
    fi

    verbose_msg "Executing -> $_CMD $pre_cmd $post_cmd"
    if sh -c "$_CMD $pre_cmd $post_cmd"; then
        if [[ $_BACKUP -eq 1 ]] && [[ $_CMD == "cp -rf" ]]; then
            local name="${post_cmd##*/}"
            if [[ -d "${_BACKUP_DIR}/${name}/host" ]] && [[ $(ls -A "${_BACKUP_DIR}/${name}/host") ]]; then
                status_msg "Restoring shell/host folder"
                verbose_msg "Restoring shell host from ${_BACKUP_DIR}/${name}/host"
                cp -rf "${_BACKUP_DIR}/${name}/host" "$post_cmd/host"
            fi
        fi
        return 0
    else
        if [[ $_CMD == "cp -rf" ]]; then
            error_msg "Fail to copy $pre_cmd"
        else
            error_msg "Fail to link $pre_cmd"
        fi
        return 1
    fi

}

function download_asset() {

    if [[ $# -lt 2 ]]; then
        error_msg "Not enough args"
        return 1
    fi

    if ! has_fetcher; then
        error_msg "This system has neither curl nor wget to download the asset $1"
        return 2
    fi

    local asset="$1"
    local url="$2"
    local dest=""
    if [[ -n "$3" ]]; then
        local dest="$3"
    fi

    local cmd=""

    if hash curl 2>/dev/null; then
        cmd='curl -L '
        if [[ $_VERBOSE -eq 0 ]]; then
            cmd="$cmd -s "
        fi
        cmd="$cmd $url"
        if [[ -n "$dest" ]]; then
            cmd="$cmd -o $dest"
        fi
    else  # If not curl, wget is available since we checked with "has_fetcher"
        cmd='wget '
        if [[ $_VERBOSE -eq 0 ]]; then
            cmd="$cmd -q "
        fi
        if [[ -n "$dest" ]]; then
            cmd="$cmd -O $dest"
        fi
        cmd="$cmd $url"
    fi

    if [[ $_BACKUP -eq 1 ]]; then
        if [[ -e "$dest" ]] || [[ -d "$dest" ]]; then
            verbose_msg "Backing up $dest into $_BACKUP_DIR"
            mv --backup=numbered "$dest" "$_BACKUP_DIR"
        fi
    elif [[ $_FORCE_INSTALL -eq 1 ]]; then
        verbose_msg "Removing $dest"
        rm -rf "$dest"
    elif [[ -e "$dest" ]] || [[ -d "$dest" ]]; then
        warn_msg "Skipping $asset, already exists in ${dest%/*}"
        return 4
    fi

    if [[ ! -d "$dest" ]] && [[ ! -f "$dest" ]]; then
        verbose_msg "Downloading $asset"
        if eval "$cmd"; then
            return 0
        else
            error_msg "Failed to download $asset"
            return 5
        fi
    else
        warn_msg "$asset already exists in $dest, skipping download"
        return 5
    fi

    return 1
}

function clone_repo() {
    local repo="$1"
    local dest="$2"

    if hash git 2>/dev/null; then
        if [[ $_BACKUP -eq 1 ]]; then
            if [[ -e "$dest" ]] || [[ -d "$dest" ]]; then
                verbose_msg "Backing up $dest into $_BACKUP_DIR"
                mv --backup=numbered "$dest" "$_BACKUP_DIR"
            fi
        elif [[ $_FORCE_INSTALL -eq 1 ]]; then
            verbose_msg "Removing $dest"
            rm -rf "$dest"
        elif [[ -e "$dest" ]] || [[ -d "$dest" ]]; then
            warn_msg "Skipping ${repo##*/}, already exists in $dest"
            return 1
        fi

        if [[ ! -d "$dest" ]] && [[ ! -f "$dest" ]]; then
            verbose_msg "Cloning $repo into $dest"
            # TODO: simplify this crap
            if [[ $_VERBOSE -eq 1 ]]; then
                if git clone --recursive "$repo" "$dest"; then
                    return 0
                fi
            else
                if git clone --quiet --recursive "$repo" "$dest" &>/dev/null; then
                    return 0
                fi
            fi
        else
            warn_msg "$dest already exists, skipping cloning"
            return 3
        fi
    else
        error_msg "Git command is not available"
        return 2
    fi
    return 1
}


function setup_bin() {
    status_msg "Getting shell functions and scripts"

    for script in "${_SCRIPT_PATH}"/bin/*; do
        local scriptname="${script##*/}"

        local file_basename="${scriptname%%.*}"
        # local file_extention="${scriptname##*.}"

        verbose_msg "Setup $script into $HOME/.local/bin/$file_basename"
        setup_config "$script" "$HOME/.local/bin/$file_basename"
    done
    return 0
}

function setup_shell() {

    local github="https://github.com"
    local rst=0

    status_msg "Getting python startup script"
    setup_config "${_SCRIPT_PATH}/scripts/pythonstartup.py" "$HOME/.local/lib/pythonstartup.py"

    status_msg "Getting dotconfigs"
    for script in "${_SCRIPT_PATH}"/dotconfigs/*; do
        local scriptname="${script##*/}"

        # local file_basename="${scriptname%%.*}"
        # local file_extention="${scriptname##*.}"

        verbose_msg "Setup $script into $HOME/.${scriptname}"
        setup_config "$script" "$HOME/.${scriptname}"
    done

    local sh_shells=(bash zsh)
    local csh_shells=(tcsh csh)

    status_msg "Getting Shell init files"

    for shell in "${sh_shells[@]}"; do
        status_msg "Setting up ${shell}rc"
        if [[ ! -f "$HOME/.${shell}rc" ]] || [[ $_FORCE_INSTALL -eq 1 ]]; then
            setup_config "${_SCRIPT_PATH}/shell/init/shellrc.sh" "$HOME/.${shell}rc"
        else
            warn_msg "The file $HOME/.${shell}rc already exists, trying $HOME/.${shell}rc.$USER"
            setup_config "${_SCRIPT_PATH}/shell/init/shellrc.sh" "$HOME/.${shell}rc.$USER"
        fi
    done

    for shell in "${csh_shells[@]}"; do
        status_msg "Setting up ${shell}rc"
        if [[ ! -f "$HOME/.${shell}rc" ]]; then
            setup_config "${_SCRIPT_PATH}/shell/init/shellrc.csh" "$HOME/.${shell}rc"
        else
            warn_msg "The file $HOME/.${shell}rc already exists, trying $HOME/.${shell}rc.$USER"
            setup_config "${_SCRIPT_PATH}/shell/init/shellrc.csh" "$HOME/.${shell}rc.$USER"
        fi
    done

    setup_config "${_SCRIPT_PATH}/shell/" "$HOME/.config/shell" || rst=1

    if hash tmux 2>/dev/null; then
        status_msg "Setting Tmux plugins"

        [[ ! -d "$HOME/.tmux/plugins/tpm" ]] && mkdir -p "$HOME/.tmux/plugins/"

        if ! clone_repo "$github/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"; then
            error_msg "Failed to clone tmux plugin manager"
            rst=1
        fi

    else
        warn_msg "Skipping tmux configs, tmux is not installed"
    fi

    return $rst
}

function setup_shell_scripts {
    local rst=0

    if [[ $_CURRENT_SHELL =~ (ba|z)?sh ]]; then
        local github='https://raw.githubusercontent.com'
        [[ ! -d "$HOME/.config/shell/scripts/" ]] && mkdir -p "$HOME/.config/shell/scripts/"

        if [[ ! -f "$HOME/.config/shell/scripts/z.sh" ]]; then
            status_msg 'Getting Z'
            local z="${github}/rupa/z/master/z.sh"
            if  download_asset "Z script" "${z}" "$_TMP/z.sh"; then
                mv "$_TMP/z.sh" "$HOME/.config/shell/scripts/z.sh"
                [[ ! -f "$HOME/.z" ]] && touch "$HOME/.z"
            else
                error_msg 'Failed to download Z script'
                rst=1
            fi
        else
            warn_msg "Z script already install"
            rst=1
        fi

    else
        error_msg "Not compatible shell ${_CURRENT_SHELL}"
        rst=1
    fi

    if has_fetcher && { ! hash screenfetch 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing screenfetch install'
        status_msg 'Getting screenfetch'
        local pkg='screenfetch'
        local url="https://git.io/vaHfR"
        if  download_asset "screenfetch script" "${url}" "$_TMP/${pkg}"; then
            mv "$_TMP/${pkg}" "$HOME/.local/bin/"
            chmod u+x "$HOME/.local/bin/${pkg}"
        else
            error_msg 'Failed to download screenfetch script'
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download screenfetch"
        rst=2
    else
        warn_msg "Skipping screenfetch, already installed"
        rst=2
    fi

    return $rst
}

function setup_git() {
    status_msg "Installing Global Git settings"
    setup_config "${_SCRIPT_PATH}/git/gitconfig" "$HOME/.gitconfig"

    status_msg "Installing Global Git templates and hooks"
    setup_config "${_SCRIPT_PATH}/git" "$HOME/.config/git"

    status_msg "Setting up local git commands"
    [[ ! -d "$HOME/.config/git/host" ]] && mkdir -p "$HOME/.config/git/host"

    # Since we are initializing the system, we want to copy our own hooks in this repo
    status_msg "Settings git hooks for the current dotfiles"
    if [[ ! -d "${_SCRIPT_PATH}/.git/hooks" ]]; then
        setup_config "${_SCRIPT_PATH}/git/templates/hooks/" "${_SCRIPT_PATH}/.git/hooks"
    else
        [[ ! -d "${_SCRIPT_PATH}/.git/hooks" ]] && mkdir -p "${_SCRIPT_PATH}/.git/hooks"
        for hooks in "${_SCRIPT_PATH}"/git/templates/hooks/*; do
            local scriptname="${script##*/}"

            local file_basename="${scriptname%%.*}"
            # local file_extention="${scriptname##*.}"

            verbose_msg "Getting $hooks into ${_SCRIPT_PATH}/.git/hooks/${hooks##*/}"

            setup_config "$hooks" "${_SCRIPT_PATH}/.git/hooks/${hooks##*/}"
        done
    fi
    return 0
}

function get_vim_dotfiles() {
    status_msg "Cloning vim dotfiles in $HOME/.vim"

    # If we couldn't clone our repo, return
    if ! clone_repo "$_URL/.vim" "$HOME/.vim"; then
        error_msg "Failed to clone Vim's configs"
        return 1
    fi

    if [[ ! -f "$HOME/.vim/vimrc" ]] && ! setup_config "$HOME/.vim/init.vim" "$HOME/.vimrc"; then
        error_msg "Vimrc link failed"
        return 1
    fi

    if [[ ! -f "$HOME/.vim/gvimrc" ]] && ! setup_config "$HOME/.vim/ginit.vim" "$HOME/.gvimrc"; then
        error_msg "gvimrc link failed"
        return 1
    fi

    # Windows stuff
    if is_windows; then

        # If we couldn't clone our repo, return
        if [[ -d "$HOME/.vim" ]] && [[ ! -d "$HOME/vimfiles" ]]; then
            status_msg "Copying vim dir into in $HOME/vimfiles"
            if ! setup_config "$HOME/.vim" "$HOME/vimfiles"; then
                error_msg "We couldn't copy vim dir"
                return 1
            fi
        else
            status_msg "Cloning vim dotfiles in $HOME/vimfiles"
            if ! clone_repo "$_URL/.vim" "$HOME/vimfiles"; then
                error_msg "Couldn't get vim repo"
                return 1
            fi
        fi

        if [[ ! -f "$HOME/vimfiles/vimrc" ]] && ! setup_config "$HOME/vimfiles/init.vim" "$HOME/_vimrc"; then
            error_msg "Vimrc link failed"
            return 1
        fi

        if [[ ! -f "$HOME/vimfiles/gvimrc" ]] && ! setup_config "$HOME/.vim/ginit.vim" "$HOME/_gvimrc"; then
            error_msg "gvimrc link failed"
            return 1
        fi

    fi

    # No errors so far
    return 0
}

# TODO: As portable note says, create flag `compile` to force compilation or jut get the pre compiled binaries
function get_nvim_dotfiles() {
    # Windows stuff
    status_msg "Setting up neovim"


    if [[ $_PORTABLES -eq 0 ]] && [[ $_ALL -eq 0 ]] && [[ $_NEOVIM_DOTFILES -eq 0 ]] && ! [[ "$_ARCH" =~ ^arm ]]; then
        local args="--portable"

        [[ $_FORCE_INSTALL -eq 1 ]] && args=" --force $args"
        [[ $_NOCOLOR -eq 1 ]] && args=" --nocolor $args"
        [[ $_VERBOSE -eq 1 ]] && args=" --verbose $args"
        [[ $_NEOVIM_DEV -eq 1 ]] && args=" --dev $args"
        if ! hash nvim 2> /dev/null || [[ $_FORCE_INSTALL -eq 1 ]]; then
            if ! eval "${_SCRIPT_PATH}/bin/get_nvim.sh ${args}"; then
                error_msg ""
                return 1
            fi
        fi
    elif [[ "$_ARCH" =~ ^arm ]]; then
        warn_msg "Skipping neovim install, Portable not available for ARM systemas"
    elif [[ $_NEOVIM_DOTFILES -eq 0 ]]; then
        verbose_msg "Skipping neovim install, already install with defaults or portables"
    fi

    if is_windows; then

        # If we couldn't clone our repo, return
        status_msg "Getting neovim in $HOME/AppData/Local/nvim"
        if [[ -d "$HOME/.vim" ]]; then
            setup_config "$HOME/.vim" "$HOME/AppData/Local/nvim"
        elif [[ -d "$HOME/vimfiles" ]]; then
            setup_config "$HOME/vimfiles" "$HOME/AppData/Local/nvim"
        else
            status_msg "Cloning neovim dotfiles in $HOME/AppData/Local/nvim"
            if ! clone_repo "$_URL/.vim" "$HOME/.config/nvim"; then
                error_msg "Fail to clone dotvim files"
                return 1
            fi
        fi

    else

        # if the current command creates a symbolic link and we already have some vim
        # settings, lets use them
        status_msg "Checking existing vim dotfiles"
        if [[ -d "$HOME/.vim" ]]; then
            [[ "$_CMD" == "ln -s" ]] && status_msg "Linking current vim dotfiles"
            [[ "$_CMD" == "cp -rf" ]] && status_msg "Copying current vim dotfiles"
            if ! setup_config "$HOME/.vim" "$HOME/.config/nvim"; then
                error_msg "Failed gettings dotvim files"
                return 1
            fi
        else
            status_msg "Cloning neovim dotfiles in $HOME/.config/nvim"
            if ! clone_repo "$_URL/.vim" "$HOME/.config/nvim"; then
                error_msg "Fail to clone dotvim files"
                return 1
            fi
        fi
    fi

    # No errors so far
    return 0
}

function _windows_portables() {
    local rst=0
    local github='https://github.com'

    if has_fetcher && { ! hash shellcheck 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; } ; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing shellcheck install'
        local pkg='shellcheck-latest.zip'
        status_msg "Getting shellcheck"
        if download_asset "Shellcheck" "https://storage.googleapis.com/shellcheck/${pkg}" "$_TMP/${pkg}"; then
            [[ -d "$_TMP/shellcheck-latest" ]] && rm -rf "$_TMP/shellcheck-latest"
            unzip -o "$_TMP/${pkg}" -d "$_TMP/shellcheck-latest"
            chmod +x "$_TMP/shellcheck-latest/shellcheck-latest.exe"
            mv "$_TMP/shellcheck-latest/shellcheck-latest.exe" "$HOME/.local/bin/shellcheck.exe"
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $_TMP/shellcheck-latest" && rm -rf "$_TMP/shellcheck-latest"
        else
            rst=1
        fi
    else
        warn_msg "Skipping shellcheck, already installed"
        rst=2
    fi

    if has_fetcher && { ! hash bat 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing bat install'
        status_msg "Getting bat"
        local pkg='bat.zip'
        local url="${github}/sharkdp/bat"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading bat version: ${version}"
        local os_type='x86_64-pc-windows-msvc'
        if download_asset "Bat" "${url}/releases/download/${version}/bat-${version}-${os_type}.zip" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            verbose_msg "Extracting into $_TMP/${pkg}"
            if ! unzip -o "$_TMP/${pkg}" -d "$_TMP/bat-${version}-${os_type}/"; then
                error_msg "An error occurred extracting zip file"
                rst=1
            else
                chmod u+x "$_TMP/bat-${version}-${os_type}/bat.exe"
                mv "$_TMP/bat-${version}-${os_type}/bat.exe" "$HOME/.local/bin/"
            fi
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $_TMP/bat-${version}-${os_type}" && rm -rf "$_TMP/bat-${version}-${os_type}/"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download Bat"
        rst=1
    else
        warn_msg "Skipping bat, already installed"
        rst=2
    fi

    if has_fetcher && { ! hash rg 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing rg install'
        status_msg "Getting rg"
        local pkg='ripgrep.zip'
        local url="${github}/BurntSushi/ripgrep"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$( curl -Ls ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$( wget -qO- ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        fi
        status_msg "Downloading rg version: ${version}"
        local os_type="${_ARCH}-pc-windows-gnu"
        if download_asset "Ripgrep" "${url}/releases/download/${version}/ripgrep-${version}-${os_type}.zip" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            verbose_msg "Extracting into $_TMP/${pkg}"
            if ! unzip -o "$_TMP/${pkg}" -d "$_TMP/ripgrep-${version}-${os_type}/"; then
                error_msg "An error occurred extracting zip file"
                rst=1
            else
                chmod u+x "$_TMP/ripgrep-${version}-${os_type}/rg.exe"
                mv "$_TMP/ripgrep-${version}-${os_type}/rg.exe" "$HOME/.local/bin/"
            fi
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $_TMP/ripgrep-${version}-${os_type}" && rm -rf "$_TMP/ripgrep-${version}-${os_type}/"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download ripgrep"
        rst=2
    else
        warn_msg "Skipping rg, already installed"
        rst=2
    fi

    if has_fetcher && { ! hash fd 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing fd install'
        status_msg "Getting fd"
        local pkg='fd.zip'
        local url="${github}/sharkdp/fd"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$( curl -Ls ${url}/tags | grep -oE 'v[0-9]\.[0-9]\.[0-9]$' | sort -u | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$( wget -qO- ${url}/tags | grep -oE 'v[0-9]\.[0-9]\.[0-9]$' | sort -u | tail -n 1)"
        fi
        status_msg "Downloading fd version: ${version}"
        local os_type="${_ARCH}-pc-windows-gnu"
        if download_asset "Fd" "${url}/releases/download/${version}/fd-${version}-${os_type}.zip" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            verbose_msg "Extracting into $_TMP/${pkg}"
            if ! unzip -o "$_TMP/${pkg}" -d "$_TMP/fd-${version}-${os_type}/"; then
                error_msg "An error occurred extracting zip file"
                rst=1
            else
                chmod u+x "$_TMP/fd-${version}-${os_type}/fd.exe"
                mv "$_TMP/fd-${version}-${os_type}/fd.exe" "$HOME/.local/bin/"
            fi
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $_TMP/fd-${version}-${os_type}" && rm -rf "$_TMP/fd-${version}-${os_type}/"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download fd"
        rst=2
    else
        warn_msg "Skipping fd, already installed"
        rst=2
    fi

    if has_fetcher && { ! hash texlab 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing texlab install'
        status_msg "Getting texlab"
        local pkg='texlab.zip'
        local url="${github}/latex-lsp/texlab"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading texlab version: ${version}"
        local os_type="${_ARCH}-windows"
        if download_asset "texlab" "${url}/releases/download/${version}/texlab-${os_type}.zip" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            verbose_msg "Extracting into $_TMP/${pkg}"
            unzip -o "$_TMP/${pkg}"
            chmod u+x "$_TMP/texlab.exe"
            mv "$_TMP/texlab.exe" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download texlab"
        rst=2
    else
        warn_msg "Skipping texlab, already installed"
        rst=2
    fi

    if is_64bits && { ! hash mc 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && { [[ -f "$HOME/.local/bin/mc.exe" ]] && status_msg 'Forcing minio client install' && rm -rf "$HOME/.local/bin/mc.exe"; }
        status_msg "Getting minio client"
        if download_asset "Minio client" "https://dl.min.io/client/mc/release/windows-amd64/mc.exe" "$HOME/.local/bin/mc.exe"; then
            chmod +x "$HOME/.local/bin/mc.exe"
        else
            rst=1
        fi
    elif ! is_64bits; then
        error_msg "Minio portable is only Available for x86 64 bits"
        rst=1
    else
        warn_msg "Skipping minio client, already installed"
        rst=2
    fi

    return $rst
}

function _linux_portables() {
    local rst=0
    local github='https://github.com'

    if ! hash fzf 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]]; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing FZF install'
        status_msg "Getting FZF"
        if ! clone_repo "${github}/junegunn/fzf" "$HOME/.fzf"; then
            error_msg "Fail to clone FZF"
            rst=1
        fi
        if [[ $_VERBOSE -eq 1 ]]; then
            if ! "$HOME/.fzf/install" --all --no-update-rc; then
                error_msg "Fail to install FZF"
                rst=1
            fi
        else
            if ! "$HOME/.fzf/install" --all --no-update-rc &>/dev/null; then
                error_msg "Fail to install FZF"
                rst=1
            fi
        fi
    else
        warn_msg "Skipping FZF, already installed"
        rst=2
    fi

    if [[ "$_ARCH" =~ ^armv6 ]]; then
        warn_msg "Skipping no ARMv6 compatible portables"
        return 2
    fi

    if has_fetcher && { ! hash bat 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing bat install'
        status_msg "Getting bat"
        local pkg='bat.tar.xz'
        local url="${github}/sharkdp/bat"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading bat version: ${version}"
        if [[ "$_ARCH" =~ ^arm ]]; then
            local os_type='arm-unknown-linux-gnueabihf'
        else
            local os_type="${_ARCH}-unknown-linux-musl"
        fi
        if download_asset "Bat" "${url}/releases/download/${version}/bat-${version}-${os_type}.tar.gz" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            verbose_msg "Extracting into $_TMP/${pkg}" && tar xf "$_TMP/${pkg}"
            chmod u+x "$_TMP/bat-${version}-${os_type}/bat"
            mv "$_TMP/bat-${version}-${os_type}/bat" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $_TMP/bat-${version}-${os_type}" && rm -rf "$_TMP/bat-${version}-${os_type}/"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download Bat"
        rst=2
    else
        warn_msg "Skipping bat, already installed"
        rst=2
    fi

    if has_fetcher && { ! hash rg 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing rg install'
        status_msg "Getting rg"
        local pkg='rg.tar.xz'
        local url="${github}/BurntSushi/ripgrep"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        fi
        status_msg "Downloading rg version: ${version}"
        if [[ "$_ARCH" =~ ^arm ]]; then
            local os_type='arm-unknown-linux-gnueabihf'
        else
            local os_type="${_ARCH}-unknown-linux-musl"
        fi
        if download_asset "Ripgrep" "${url}/releases/download/${version}/ripgrep-${version}-${os_type}.tar.gz" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            verbose_msg "Extracting into $_TMP/${pkg}" && tar xf "$_TMP/${pkg}"
            chmod u+x "$_TMP/ripgrep-${version}-${os_type}/rg"
            mv "$_TMP/ripgrep-${version}-${os_type}/rg" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $_TMP/ripgrep-${version}-${os_type}" && rm -rf "$_TMP/ripgrep-${version}-${os_type}"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download ripgrep"
        rst=2
    else
        warn_msg "Skipping ripgrep, already installed"
        rst=2
    fi

    if has_fetcher && { ! hash fd 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing fd install'
        status_msg "Getting fd"
        local pkg='fd.tar.xz'
        local url="${github}/sharkdp/fd"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | tail -n 1)"
        fi
        status_msg "Downloading fd version: ${version}"
        if [[ "$_ARCH" =~ ^arm ]]; then
            local os_type='arm-unknown-linux-gnueabihf'
        else
            local os_type="${_ARCH}-unknown-linux-musl"
        fi
        if download_asset "Fd" "${url}/releases/download/${version}/fd-${version}-${os_type}.tar.gz" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            verbose_msg "Extracting into $_TMP/${pkg}" && tar xf "$_TMP/${pkg}"
            chmod u+x "$_TMP/fd-${version}-${os_type}/fd"
            mv "$_TMP/fd-${version}-${os_type}/fd" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $_TMP/fd-${version}-${os_type}" && rm -rf "$_TMP/fd-${version}-${os_type}/"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download fd"
        rst=2
    else
        warn_msg "Skipping fd, already installed"
        rst=2
    fi

    if [[ "$_ARCH" =~ ^arm ]]; then
        warn_msg "Skipping no ARM compatible portables"
        return 2
    fi

    if has_fetcher && { ! hash shellcheck 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]]; } && [[ $_ARCH == 'x86_64' ]]; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing shellcheck install'
        status_msg "Getting shellcheck"
        local pkg='shellcheck.tar.xz'
        if download_asset "Shellcheck" "https://storage.googleapis.com/shellcheck/shellcheck-latest.linux.x86_64.tar.xz" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            verbose_msg "Extracting into $_TMP/${pkg}" && tar xf "$_TMP/${pkg}"
            chmod u+x "$_TMP/shellcheck-latest/shellcheck"
            mv "$_TMP/shellcheck-latest/shellcheck" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            verbose_msg "Cleanning up data $_TMP/shellcheck-latest/" && rm -rf "$_TMP/shellcheck-latest/"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! hash shellcheck 2>/dev/null && [[ ! $_ARCH == 'x86_64' ]] ; then
        warn_msg "Shellcheck does not have prebuild binaries for non 64 bits x86 devices"
        rst=2
    else
        warn_msg "Skipping shellcheck, already installed"
        rst=2
    fi

    if is_64bits && has_fetcher && { ! hash texlab 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing texlab install'
        status_msg "Getting texlab"
        local pkg='texlab.tar.gz'
        local url="${github}/latex-lsp/texlab"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$(curl -Ls ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$(wget -qO- ${url}/tags | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+$' | sort -uh | head -n 1)"
        fi
        status_msg "Downloading texlab version: ${version}"
        local os_type="${_ARCH}-linux"
        if download_asset "texlab" "${url}/releases/download/${version}/texlab-${os_type}.tar.gz" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            verbose_msg "Extracting into $_TMP/${pkg}" && tar xf "$_TMP/${pkg}"
            chmod u+x "$_TMP/texlab"
            mv "$_TMP/texlab" "$HOME/.local/bin/"
            verbose_msg "Cleanning up pkg ${_TMP}/${pkg}" && rm -rf "${_TMP:?}/${pkg}"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! is_64bits; then
        error_msg "Texlab portable is only Available for x86 64 bits"
        rst=1
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download texlab"
        rst=2
    else
        warn_msg "Skipping texlab, already installed"
        rst=2
    fi

    if is_64bits && has_fetcher && { ! hash mc 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && { [[ -f "$HOME/.local/bin/mc" ]] && status_msg 'Forcing minio client install' && rm -rf "$HOME/.local/bin/mc"; }
        status_msg "Getting minio client"
        if download_asset "MinioClient" "https://dl.min.io/client/mc/release/linux-amd64/mc" "$HOME/.local/bin/mc"; then
            chmod +x "$HOME/.local/bin/mc"
        else
            rst=1
        fi
    elif ! is_64bits; then
        error_msg "Minio portable is only Available for x86 64 bits"
        rst=1
    else
        warn_msg "Skipping minio client, already installed"
        rst=2
    fi

    if has_fetcher && { ! hash jq 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing jq install'
        status_msg "Getting jq"
        local pkg='jq'
        local url="${github}/stedolan/jq"
        if hash curl 2>/dev/null; then
            # shellcheck disable=SC2155
            local version="$( curl -Ls ${url}/tags | grep -oE 'jq-[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        else
            # shellcheck disable=SC2155
            local version="$( wget -qO- ${url}/tags | grep -oE 'jq-[0-9]+\.[0-9]+$' | sort -u | tail -n 1)"
        fi
        status_msg "Downloading jq version: ${version}"
        local os_type="linux32"
        if is_64bits; then
            os_type="linux64"
        fi
        if download_asset "jq" "${url}/releases/download/${version}/jq-${os_type}" "$_TMP/${pkg}"; then
            pushd "$_TMP" 1> /dev/null || return 1
            chmod u+x "$_TMP/${pkg}"
            mv "$_TMP/${pkg}" "$HOME/.local/bin/"
            popd 1> /dev/null || return 1
        else
            rst=1
        fi
    elif ! has_fetcher; then
        error_msg "No curl neither wget to download jq"
        rst=2
    else
        warn_msg "Skipping jq, already installed"
        rst=2
    fi

    return $rst
}

# TODO: Add GNU global as a windows portable
# TODO: Add compile option to auto compile some programs
function get_portables() {
    local rst=0

    local github='https://github.com'

    if ! [[ "$_ARCH" =~ ^arm ]] && { ! hash nvim 2>/dev/null || [[ $_FORCE_INSTALL -eq 1 ]] ; }; then
        [[ $_FORCE_INSTALL -eq 1 ]] && status_msg 'Forcing Neovim install'
        status_msg "Getting Neovim"

        local args="--portable"

        [[ $_FORCE_INSTALL -eq 1 ]] && args=" --force $args"
        [[ $_NOCOLOR -eq 1 ]] && args=" --nocolor $args"
        [[ $_VERBOSE -eq 1 ]] && args=" --verbose $args"
        [[ $_NEOVIM_DEV -eq 1 ]] && args=" --dev $args"

        if ! eval "${_SCRIPT_PATH}/bin/get_nvim.sh ${args}"; then
            error_msg "Fail to install Neovim"
            rst=1
        fi
    elif [[ "$_ARCH" =~ ^arm ]]; then
        warn_msg "Skipping neovim install, Portable not available for ARM systemas"
    else
        warn_msg "Skipping Neovim, already installed"
        rst=2
    fi

    status_msg "Checking portable programs"
    if has_fetcher; then
        if is_windows; then
            _windows_portables
            rst=$?
        elif is_osx; then
            warn_msg "mac support is WIP"
            return 0
        else
            _linux_portables
            rst=$?
        fi
    else
        error_msg "Curl is not available to download portables"
        return 1
    fi
    return $rst
}


function get_emacs_dotfiles() {
    status_msg "Installing Evil Emacs"

    # If we couldn't clone our repo, return
    clone_repo "$_URL/.emacs.d" "$HOME/.emacs.d" && return $?

    # verbose_msg "Creating dir $HOME/.config/systemd/user" && mkdir -p "$HOME/.config/systemd/user"
    # if setup_config "${_SCRIPT_PATH}/services/emacs.service" "$HOME/.config/systemd/user/emacs.service"
    # then
    #     return 0
    # fi

    return 0
}

function setup_shell_framework() {
    status_msg "Getting shell framework"

    local args=""

    [[ $_FORCE_INSTALL -eq 1 ]] && args=" --force $args"
    [[ $_NOCOLOR -eq 1 ]] && args=" --nocolor $args"
    [[ $_VERBOSE -eq 1 ]] && args=" --verbose $args"

    verbose_msg "Calling get_shell as -> ${_SCRIPT_PATH}/bin/get_shell.sh $args -s $_CURRENT_SHELL"
    eval "${_SCRIPT_PATH}/bin/get_shell.sh $args -s $_CURRENT_SHELL" || return 1

    return 0
}

function get_dotfiles() {
    _SCRIPT_PATH="$HOME/.local/dotfiles"

    status_msg "Installing dotfiles in $_SCRIPT_PATH"

    [[ ! -d "$HOME/.local/" ]] && mkdir -p "$HOME/.local/"

    if clone_repo "$_URL/dotfiles" "$_SCRIPT_PATH"; then
        return 0
    fi
    return 1
}

function get_cool_fonts() {
    local github='https://github.com'
    if [[ -z $SSH_CONNECTION ]]; then
        status_msg "Gettings powerline fonts"
        if clone_repo "${github}/powerline/fonts" "$HOME/.local/fonts"; then
            if is_windows; then
                # We could indeed run $ powershell $HOME/.local/fonts/install.ps1
                # BUT administrator promp will pop up for EVERY font (too fucking much)
                warn_msg "Please run $HOME/.local/fonts/install.ps1 inside administrator's powershell"
            else
                if is_osx; then
                    mkdir -p "$HOME/Library/Fonts"
                fi
                status_msg "Installing cool fonts"
                if [[ $_VERBOSE -eq 1 ]]; then
                    "$HOME"/.local/fonts/install.sh
                else
                    "$HOME"/.local/fonts/install.sh 1> /dev/null
                fi
            fi
        else
            error_msg "Fail to install cool fonts"
        fi

    else
        warn_msg "We cannot install cool fonts in a remote session, please run this in you desktop environment"
    fi
    return 0
}

function setup_systemd() {
    if ! is_windows && ! is_osx; then
        if hash systemctl 2> /dev/null; then
            status_msg "Setting up User's systemd services"
            if [[ -d "$HOME/.config/systemd/user" ]] && [[ $_FORCE_INSTALL -eq 1 ]]; then
                [[ $_FORCE_INSTALL -eq 1 ]] && { warn_msg "Removing old systemd dir" && rm -rf "$HOME/.config/systemd/user"; }
                setup_config "${_SCRIPT_PATH}/systemd/user" "$HOME/.config/systemd/user"
            elif [[ -d "$HOME/.config/systemd/user/" ]]; then
                warn_msg "Systemd folder already exist, copying files manually, files won't be auto updated"
                for service in "${_SCRIPT_PATH}"/systemd/user/*.service; do
                    local servicename="${service##*/}"

                    local file_basename="${servicename%%.*}"
                    # local file_extention="${scriptname##*.}"

                    verbose_msg "Setup $service in $HOME/.config/systemd/user/${servicename}"
                    setup_config "${service}" "$HOME/.config/systemd/user/${servicename}"
                done
            else
                [[ ! -d "$HOME/.config/systemd/" ]] && mkdir -p "$HOME/.config/systemd/"
                setup_config "${_SCRIPT_PATH}/systemd/user/" "$HOME/.config/systemd/user"
            fi
            status_msg "Please reload user's units with 'systemctl --user daemon-reload'"
            # status_msg "Reloding User's units"
            # systemctl --user daemon-reload
        else
            warn_msg "This system doesn't have systemd package"
            return 1
        fi
    else
        warn_msg "Systemd's services work just in Linux environment"
        return 1
    fi
    return 0
}

function _get_pip() {
    local version="$1"

    if [[ $_FORCE_INSTALL -eq 1 ]] || ! hash "pip${version}" 2>/dev/null; then

        if [[ ! -f "$_TMP/get-pip.py" ]]; then
            if ! download_asset "PIP" "https://bootstrap.pypa.io/get-pip.py" "$_TMP/get-pip.py"; then
                return 1
            fi
            chmod u+x "$_TMP/get-pip.py"
        fi

        if [[ $version -eq 3 ]]; then
            local python=("9" "8" "7" "6" "5" "4")
            for version in "${python[@]}"; do
                if hash "python3.${version}" 2>/dev/null; then
                    status_msg "Installing pip3 with python3.${version}"
                    if [[ $_VERBOSE -eq 1 ]]; then
                        if "python3.${version}" "$_TMP/get-pip.py" --user; then
                            break
                        else
                            error_msg "Fail to install pip for python3.${version}"
                            return 1
                        fi
                    else
                        if "python3.${version}" "$_TMP/get-pip.py" --user 1>/dev/null; then
                            break
                        else
                            error_msg "Fail to install pip for python3.${version}"
                            return 1
                        fi
                    fi
                fi
            done
        else
            status_msg "Installing pip2"
            if [[ $_VERBOSE -eq 1 ]]; then
                if ! python2 $_TMP/get-pip.py --user; then
                    error_msg "Fail to install pip for python2"
                    return 1
                fi
            else
                if ! python2 $_TMP/get-pip.py --user 1>/dev/null; then
                    error_msg "Fail to install pip for python2"
                    return 1
                fi
            fi
        fi
    else
        warn_msg "Skipping pip, already installed"
    fi

    return 0
}

function setup_python() {

    if [[ $_PYTHON_VERSION == 'all' ]]; then
        # Start to setup just python3 by default since python2 is officially deprecated
        # Python2 can be set with --python=2
        local versions=(3)
    else
        local versions=("$_PYTHON_VERSION")
    fi

    for version in "${versions[@]}"; do

        if [[ $_FORCE_INSTALL -eq 1 ]] || ! hash "pip${version}" 2>/dev/null; then
            if ! _get_pip "$version"; then
                continue
            fi
        fi

        if ! hash "pip${version}" 2>/dev/null; then
            error_msg "Failed to locate pip${version} executable in the path"
            continue
        fi

        if [[ ! -f "${_SCRIPT_PATH}/packages/${_OS}/python${version}/requirements.txt" ]]; then
            warn_msg "Skipping requirements for pip ${version} in OS: ${_OS}"
        else
            [[ $_OS == unknown ]] && warn_msg "Unknown OS, trying to install generic pip packages"
            status_msg "Setting up python ${version} dependencies"
            verbose_msg "Using ${_SCRIPT_PATH}/packages/${_OS}/python${version}/requirements.txt"

            if [[ $_VERBOSE -eq 1 ]]; then
                local quiet=""
            else
                # shellcheck disable=SC2034
                local quiet="--quiet"
            fi
            if [[ -z $VIRTUAL_ENV ]]; then
                # shellcheck disable=SC2016
                local cmd="pip${version} install ${quiet} --user -r ${_SCRIPT_PATH}/packages/${_OS}/python${version}/requirements.txt"
            else
                # shellcheck disable=SC2016
                local cmd="pip${version} install ${quiet} -r ${_SCRIPT_PATH}/packages/${_OS}/python${version}/requirements.txt"
            fi
            verbose_msg "Pip command --> ${cmd}"
            if ! eval "$cmd"; then
                error_msg "Fail to install python ${version} dependencies"
            fi
        fi
    done

    return 0
}

function setup_pkgs() {
    local rc=0
    if is_osx; then
        warn_msg "macOS support still WIP"
    else
        if ! is_windows && [[ $EUID -ne 0 ]] && [[ ! $(groups) =~ sudo ]]; then
            error_msg "User: ${USER} is neither root nor belongs to the sudo group"
            return 1
        elif is_windows; then
            warn_msg "Windows package install must be run from privilege Git bash terminal"
        fi
        local cmd=""
        if [[ -z "$_PKG_FILE" ]]; then
            if ! ls "${_SCRIPT_PATH}/packages/${_OS}"/*.pkg > /dev/null; then
                error_msg "No package file for \"${_OS}\" OS"
                return 2
            fi
            declare -a pkgs=( "${_SCRIPT_PATH}/packages/${_OS}"/*.pkg )
        elif [[ -f "$_PKG_FILE" ]]; then
            local pkgs=( "$_PKG_FILE" )
        else
            local pkgs=( "${_SCRIPT_PATH}/packages/${_OS}/${_PKG_FILE}.pkg" )
        fi
        for pkg in "${pkgs[@]}"; do
            verbose_msg "Package file $pkg"
            local cmd=""
            local filename
            filename=$(basename "$pkg")
            local cmdname="${filename%.pkg}"
            if ! hash "${cmdname}"; then
                warn_msg "Skipping pacakges from ${filename}, ${cmdname} is not install or missing in the PATH"
                continue
            fi
            while IFS= read -r line; do
                if [[ -z "$cmd" ]] && [[ "$line" =~ ^sudo\ .* ]] && [[ $EUID -eq 0 ]]; then
                    # remove sudo instruction if root user is running the script
                    cmd="${line##*sudo}"
                elif [[ ! "$line" =~ ^#.* ]]; then # if the line starts with "#" then it's a comment
                    cmd="$cmd $line"
                fi
            done < "$pkg"
            status_msg "Installing packages from ${cmdname}"
            # if [[ $_VERBOSE -eq 0 ]]; then
            #     cmd="$cmd"
            # fi
            verbose_msg "Using command $cmd"
            if ! eval "$cmd"; then
                error_msg "Fail to install packages from ${cmdname}"
                rc=1
            fi
        done
    fi
    return $rc
}

function version() {

    if [[ -f "${_SCRIPT_PATH}/shell/banner" ]]; then
        cat "${_SCRIPT_PATH}/shell/banner"
    fi

    cat<<EOF
Mike's install script

    Author   : Mike 8a
    Version  : ${_VERSION}
    Date     : Fri 07 Jun 2019
EOF
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --backup)
            _BACKUP=1
            ;;
        --backup=*)
            _result=$(__parse_args "$key" "backup")
            if [[ $_result == "$key" ]]; then
                error_msg "Not a valid backupdir $_result"
                exit 1
            fi
            _BACKUP=1
            _BACKUP_DIR="$_result"
            ;;
        -p|--protocol)
            if [[ ! "$2" =~ ^(git|https|ssh)$ ]]; then
                error_msg "Not a valid protocol $2"
                exit 1
            fi
            _PROTOCOL="$2"
            shift
            ;;
        --protocol=*)
            _result=$(__parse_args "$key" "protocol" '(https|git|ssh)')
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid protocol $_result"
                exit 1
            fi
            _PROTOCOL="$_result"
            ;;
        --host)
            _GIT_HOST="$2"
            shift
            ;;
        --host=*)
            _result=$(__parse_args "$key" "githost")
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid host $_result"
                exit 1
            fi
            _GIT_HOST="$_result"
            ;;
        --user)
            _GIT_USER="$2"
            shift
            ;;
        --user=*)
            _result=$(__parse_args "$key" "gituser")
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid gituser $_result"
                exit 1
            fi
            _GIT_USER="$_result"
            ;;
        --url)
            if [[ ! "$2" =~ ^(https://|git://|git@)[a-zA-Z0-9.:@_-/~]+$ ]]; then
                error_msg "Not a valid url $2"
                exit 1
            fi
            _URL="$2"
            shift
            ;;
        --url=*)
            _result=$(__parse_args "$key" "url" '(https://|git://|git@)[a-zA-Z0-9.:@_-/~]+')
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid url $_result"
                exit 1
            fi
            _URL="$_result"
            ;;
        -y|--systemd)
            _SYSTEMD=1
            _ALL=0
            ;;
        -t|--portable|--portables)
            _PORTABLES=1
            _ALL=0
            ;;
        --fonts|--powerline)
            _COOL_FONTS=1
            _ALL=0
            ;;
        -c|--copy)
            _CMD="cp -rf"
            ;;
        -s|--shell)
            _SHELL=1
            _ALL=0
            ;;
        --shell_scripts)
            _SHELL=1
            _SHELL_SCRIPTS=1
            _ALL=0
            ;;
        --shell_frameworks=*)
            _result=$(__parse_args "$key" "shell_frameworks" '(ba|z)sh')
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid shell ${_result##*=}, available shell are bash and zsh"
                exit 1
            fi
            _CURRENT_SHELL="$_result"
            _SHELL_FRAMEWORK=1
            _ALL=0
            ;;
        -w|--shell_frameworks)
            _SHELL_FRAMEWORK=1
            _ALL=0
            if [[ "$2" =~ ^(ba|z)sh$ ]]; then
                _CURRENT_SHELL="$2"
                shift
            fi
            ;;
        -f|--force)
            _FORCE_INSTALL=1
            ;;
        -d|--dotfiles)
            _DOTFILES=1
            _ALL=0
            ;;
        -e|--emacs)
            _EMACS=1
            _ALL=0
            ;;
        -v|--vim)
            _VIM=1
            _ALL=0
            ;;
        --nvim=*)
            _result=$(__parse_args "$key" "nvim" '(dotfiles|stable|dev(elop(ment)?)?)')
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid neovim build type ${_result##*=}"
                exit 1
            fi
            if [[ $_result == 'dotfiles' ]]; then
                _NEOVIM_DOTFILES=1
            elif [[ $_result =~ ^dev(elop(ment)?)?$ ]]; then
                _NEOVIM_DEV=1
            else
                _NEOVIM_DEV=0
            fi
            _NVIM=1
            _ALL=0
            ;;
        -n|--neovim|--nvim)
            _NVIM=1
            _ALL=0
            if [[ "$2" =~ ^stable$ ]]; then
                _NEOVIM_DEV=0
                shift
            elif [[ "$2" =~ ^dotfiles$ ]]; then
                _NEOVIM_DEV=0
                _NEOVIM_DOTFILES=1
                shift
            elif [[ "$2" =~ ^dev(elop(ment)?)?$ ]]; then
                _NEOVIM_DEV=1
                shift
            fi
            ;;
        -b|--bin)
            _BIN=1
            _ALL=0
            ;;
        --python=*)
            _result=$(__parse_args "$key" "python" '(2|3)')
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid python version ${_result##*=}"
                exit 1
            fi
            _PYTHON_VERSION="$_result"
            _PYTHON=1
            _ALL=0
            ;;
        --python)
            _PYTHON=1
            _ALL=0
            if [[ "$2" =~ ^(2|3)$ ]]; then
                _PYTHON_VERSION="$2"
                shift
            fi
            ;;
        -g|--git)
            _GIT=1
            _ALL=0
            ;;
        --pkgs=*)
            _result=$(__parse_args "$key" "pkgs")
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid package file ${_result##*=}"
                exit 1
            elif [[ ! -f "$_result" ]]; then
                error_msg "Package file $_result does not exists"
                exit 1
            elif [[ ! "$_result" =~ \.pkg$ ]]; then
                error_msg "$_result is not a valid package file, the file must have .pkg extention"
                exit 1
            fi
            _PKG_FILE="$_result"
            _PKGS=1
            if [[ "$2" =~ ^--only$ ]]; then
                _ALL=0
                shift
            fi
            ;;
        --packages=*)
            _result=$(__parse_args "$key" "packages")
            if [[ "$_result" == "$key" ]]; then
                error_msg "Not a valid package file ${_result##*=}"
                exit 1
            elif [[ ! -f "$_result" ]]; then
                error_msg "Package file $_result does not exists"
                exit 1
            elif [[ ! "$_result" =~ \.pkg$ ]] || [[ ! -f "${_SCRIPT_PATH}/packages/${_OS}/${_result}.pkg" ]]; then
                error_msg "$_result is not a valid package file, the file must have .pkg extention"
                exit 1
            fi
            _PKG_FILE="$_result"
            _PKGS=1
            if [[ "$2" =~ ^--only$ ]]; then
                _ALL=0
                shift
            fi
            ;;
        --pkgs|--packages)
            _PKGS=1
            if [[ ! "$2" =~ ^-(-)?.*$ ]] ; then
                if [[ -f "$2" ]] && [[ "$2" =~ \.pkg$ ]] ; then
                    _PKG_FILE="$2"
                    shift
                elif [[ -f "${_SCRIPT_PATH}/packages/${_OS}/${2}.pkg" ]]; then
                    _PKG_FILE="$2"
                    shift
                fi
            fi

            if [[ "$2" =~ ^--only$ ]]; then
                _ALL=0
                shift
            fi
            ;;
        --nolog)
            _NOLOG=1
            ;;
        --verbose)
            _VERBOSE=1
            ;;
        -h|--help)
            help_user
            exit 0
            ;;
        --nocolor)
            _NOCOLOR=1
            ;;
        --version)
            version
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

initlog

[[ ! -d "$HOME/.local/bin" ]] && verbose_msg "Creating dir $HOME/.local/bin" && mkdir -p "$HOME/.local/bin"
[[ ! -d "$HOME/.local/lib" ]] && verbose_msg "Creating dir $HOME/.local/lib" && mkdir -p "$HOME/.local/lib"
[[ ! -d "$HOME/.config/" ]]   && verbose_msg "Creating dir $HOME/.config/" && mkdir -p "$HOME/.config/"

# Because the "cp -rf" means there are no symbolic links
# we must be sure we wont screw the shell host settings
if is_windows || [[ $_CMD == "cp -rf" ]]; then
    verbose_msg "Activating backup"
    _BACKUP=1
fi

if [[ $_BACKUP -eq 1 ]]; then
    status_msg "Preparing backup dir ${_BACKUP_DIR}"
    mkdir -p "${_BACKUP_DIR}"
fi

if [[ -z $_URL ]]; then
    case $_PROTOCOL in
        ssh)
            _URL="git@$_GIT_HOST:$_GIT_USER"
            ;;
        https|http)
            _URL="$_PROTOCOL://$_GIT_HOST/$_GIT_USER"
            ;;
        git)
            warn_message "Git protocol has not been tested, yet"
            _URL="git://$_GIT_HOST/$_GIT_USER"
            ;;
        *)
            _URL="https://$_GIT_HOST/$_GIT_USER"
            ;;
    esac
fi

verbose_msg "Using ${_URL}"
verbose_msg "Protocol      : ${_PROTOCOL}"
verbose_msg "User          : ${_GIT_USER}"
verbose_msg "Host          : ${_GIT_HOST}"
verbose_msg "Backup Enable : ${_BACKUP}"
verbose_msg "Log Disable   : ${_NOLOG}"
verbose_msg "Current Shell : ${_CURRENT_SHELL}"
verbose_msg "Platform      : ${SHELL_PLATFORM}"
verbose_msg "OS Name       : ${_OS}"
verbose_msg "Architecture  : ${_ARCH}"

# If the user request the dotfiles or the script path doesn't have the full files
# (the command may be executed using `curl`)
if [[ $_DOTFILES -eq 1 ]] || [[ ! -d "${_SCRIPT_PATH}/shell" ]]; then
    if ! get_dotfiles; then
        error_msg "Could not install dotfiles"
        exit 1
    fi
fi

if [[ $_ALL -eq 1 ]]; then
    verbose_msg 'Setting up everything'
    setup_bin
    setup_shell
    setup_shell_scripts
    setup_shell_framework
    setup_git
    get_portables
    get_vim_dotfiles
    get_nvim_dotfiles
    get_emacs_dotfiles
    get_cool_fonts
    setup_systemd
    setup_python
else
    [[ $_BIN -eq 1 ]] && setup_bin
    [[ $_SHELL -eq 1 ]] && setup_shell
    [[ $_SHELL_SCRIPTS -eq 1 ]] && setup_shell_scripts
    [[ $_SHELL_FRAMEWORK -eq 1 ]] && setup_shell_framework
    [[ $_GIT -eq 1 ]] && setup_git
    [[ $_PORTABLES -eq 1 ]] && get_portables
    [[ $_VIM -eq 1 ]] && get_vim_dotfiles
    [[ $_NVIM -eq 1 ]] && get_nvim_dotfiles
    [[ $_EMACS -eq 1 ]] && get_emacs_dotfiles
    [[ $_COOL_FONTS -eq 1 ]] && get_cool_fonts
    [[ $_SYSTEMD -eq 1 ]] && setup_systemd
    [[ $_PYTHON -eq 1 ]] && setup_python
fi

if [[ $_PKGS -eq 1 ]]; then
    setup_pkgs
fi

if [[ $_ERR_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0
