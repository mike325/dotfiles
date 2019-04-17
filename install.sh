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
_COOL_FONTS=0
_SHELL=0
_VIM=0
_NVIM=0
_BIN=0
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
# _GIT_SSH=0

_VERSION="0.2.0"

_NAME="$0"
_NAME="${_NAME##*/}"

_SCRIPT_PATH="$0"

_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

if hash realpath 2>/dev/null; then
    _SCRIPT_PATH=$(realpath "$_SCRIPT_PATH")
else
    pushd "$_SCRIPT_PATH" 1> /dev/null || exit 1
    _SCRIPT_PATH="$(pwd -P)"
    popd 1> /dev/null || exit 1
fi

_TMP="/tmp/"

_CMD="ln -s"

_PROTOCOL="https"
_GIT_USER="mike325"
_GIT_HOST="github.com"
_URL=""

# _DEFAULT_SHELL="${SHELL##*/}"
_CURRENT_SHELL="bash"

if [ -z "$SHELL_PLATFORM" ]; then
    export SHELL_PLATFORM='UNKNOWN'
    case "$OSTYPE" in
      *'linux'*   ) export SHELL_PLATFORM='LINUX' ;;
      *'darwin'*  ) export SHELL_PLATFORM='OSX' ;;
      *'freebsd'* ) export SHELL_PLATFORM='BSD' ;;
      *'cygwin'*  ) export SHELL_PLATFORM='CYGWIN' ;;
      *'msys'*    ) export SHELL_PLATFORM='MSYS' ;;
    esac
fi

# Windows stuff
if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then
    # Windows bash does not have pgrep by default
    # shellcheck disable=SC2009
    _CURRENT_SHELL="$(ps | grep $$ | awk '{ print $8 }')"
    _CURRENT_SHELL="${_CURRENT_SHELL##*/}"

    # Horrible hack
    if [[ $_CURRENT_SHELL =~ "ps" ]]; then
        _CURRENT_SHELL="$(ps | tail -n 1 | awk '{ print $8 }')"
        _CURRENT_SHELL="${_CURRENT_SHELL##*/}"
    fi

    # Windows does not support links we will use cp instead
    _CMD="cp -rf"
    USER="$USERNAME"
else
    _CURRENT_SHELL="$(ps | head -2 | tail -n 1 | awk '{ print $4 }')"
    # Hack when using sudo
    # TODO: Must fix this
    if [[ $_CURRENT_SHELL == "sudo" ]] || [[ $_CURRENT_SHELL == "su" ]]; then
        _CURRENT_SHELL="$(ps | head -4 | tail -n 1 | awk '{ print $4 }')"
    fi
fi

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

# TODO:
# 1) Add colors to the script
# 2) Improve Neovim and portables install

function help_user() {
    echo ""
    echo "  Simple installer of this dotfiles, by default install (link) all settings and configurations"
    echo "  if any flag ins given, the script will install just want is being told to do."
    echo "      By default command (if none flag is given): $_NAME -s -a -e -v -n -b -g -y -t --fonts"
    echo ""
    echo "  Usage:"
    echo "      $_NAME [OPTIONAL]"
    echo ""
    echo "      Optional Flags"
    echo "          --host"
    echo "              Change default git host, the new host (ex. gitlab.com) must have the following repos"
    echo "                  - .vim"
    echo "                  - .emacs.d"
    echo "                  - dotfiles"
    echo ""
    echo "          --user"
    echo "              Change default git user, the new user (ex. mike325) must have the following repos"
    echo "                  - .vim"
    echo "                  - .emacs.d"
    echo "                  - dotfiles"
    echo ""
    echo "          -p, --protocol"
    echo "              Alternate between different git protocol"
    echo "                  - https (default)"
    echo "                  - ssh"
    echo "                  - git (not tested)"
    echo ""
    echo "          --url"
    echo "              Provie full git url (ex. https://gitlab.com/mike325), the new base user mus have"
    echo "              the following repos"
    echo "                  - .vim"
    echo "                  - .emacs.d"
    echo "                  - dotfiles"
    echo ""
    echo "          --backup, --backup=DIR"
    echo "              Backup all existing files into $HOME/.local/backup or the provided dir"
    echo "              ----    Backup will be auto activated if windows is running or '-c/--copy' flag is used"
    echo ""
    echo "          -f, --force"
    echo "              Force installation, remove all previous conflict files before installing"
    echo "              This flag is always disable by default"
    echo ""
    echo "          -w, --shell_frameworks"
    echo "              Install shell frameworks, bash-it or oh-my-zsh according to the current shell"
    echo "              Current shell:   $_CURRENT_SHELL"
    echo ""
    echo "          -c, --copy"
    echo "              By default all dotfiles are linked using 'ln -s' command, this flag change"
    echo "              the command to 'cp -rf' this way you can remove the folder after installation"
    echo "              but you need to re-download the files each time you want to update the files"
    echo "              ----    Ignored option in Windows platform"
    echo "              ----    WARNING!!! if you use the option -f/--force all host Setting will be deleted!!!"
    echo ""
    echo "          -s, --shell"
    echo "              Install:"
    echo "                  - Shell alias in $HOME/.config/shell"
    echo "                  - Shell basic configurations \${SHELL}rc for bash, zsh, tcsh and csh"
    echo "                  - Everything inside ./dotconfigs into $HOME"
    echo "                  - Python startup script in $HOME/.local/lib/"
    echo ""
    echo "          -d, --dotfiles"
    echo "              Download my dotfiles repo in case, this options is meant to be used in case this"
    echo "              script is standalone executed"
    echo "                  Default URL: $_PROTOCOL://$_GIT_HOST/$_GIT_USER/dotfiles"
    echo ""
    echo "          -e, --emacs"
    echo "              Download and install my evil Emacs dotfiles"
    echo "                  Default URL: $_PROTOCOL://$_GIT_HOST/$_GIT_USER/.emacs.d"
    echo ""
    echo "          -v, --vim"
    echo "              Download and install my Vim dotfiles"
    echo "                  Default URL: $_PROTOCOL://$_GIT_HOST/$_GIT_USER/.vim"
    echo ""
    echo "          -n, --neovim"
    echo "              Download Neovim executable (portable in windows and linux) if it hasn't been Installed"
    echo "              Download and install my Vim dotfiles in Neovim's dir."
    echo "              Check if vim dotfiles are already install and copy/link (depends of '-c/copy' flag)"
    echo "              them, otherwise download them from my vim's dotfiles repo"
    echo "                  Default URL: $_PROTOCOL://$_GIT_HOST/$_GIT_USER/.vim"
    echo ""
    echo "          -b, --bin"
    echo "              Install shell functions and scripts in $HOME/.local/bin"
    echo ""
    echo "          -g, --git"
    echo "              Install git configurations into $HOME/.config/git and $HOME/.gitconfig"
    echo "              Install:"
    echo "                  - Gitconfigs"
    echo "                  - Hooks"
    echo "                  - Templates"
    echo ""
    echo "          -t, --portables"
    echo "              Install isolated/portable programs into $HOME/.local/bin"
    echo "              Install:"
    echo "                  - pip2 and pip3 (GNU/Linux only)"
    echo "                  - shellcheck"
    echo ""
    echo "          --fonts, --powerline"
    echo "              Install the powerline patched fonts"
    echo "                  * Since the patched fonts have different install method for Windows"
    echo "                    they are just download"
    echo "                  * This options is ignored if the install script is executed in a SSH session"
    echo ""
    echo "          -y, systemd"
    echo "              Install user's systemd services (Just in Linux systems)"
    echo "                  * Services are install in $HOME/.config/systemd/user"
    echo ""
    echo "          -h, --help"
    echo "              Display help, if you are seeing this, that means that you already know it (nice)"
    echo ""
    echo "          --version"
    echo "              Display the version and exit"
    echo ""
    echo "          --nocolor"
    echo "              Disable color output"
    echo ""
    echo "          --verbose"
    echo "              Output debug messages"
    echo ""
}

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        error_msg "Internal error in __parse_args function trying to parse $1"
        exit 1
    fi

    local arg="$1"
    local name="$2"

    local pattern="^--${name}[=][a-zA-Z0-9.:@_-/~]+$"

    if [[ -n "$3" ]]; then
        local pattern="^--${name}[=]$3$"
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
    sh -c "$_CMD $pre_cmd $post_cmd" && return 0 || return "$?"
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

        verbose_msg "Cloning $repo into $dest"
        # TODO: simplify this crap
        if [[ $_VERBOSE -eq 1 ]]; then
            if git clone --recursive "$repo" "$dest"; then
                return 0
            fi
        else
            if git clone --recursive "$repo" "$dest" 1>/dev/null; then
                return 0
            fi
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

    status_msg "Getting python startup script"
    setup_config "${_SCRIPT_PATH}/scripts/pythonstartup.py" "$HOME/.local/lib/pythonstartup.py"

    status_msg "Getting dotconfigs"
    for script in "${_SCRIPT_PATH}"/dotconfigs/*; do
        local scriptname="${script##*/}"

        local file_basename="${scriptname%%.*}"
        # local file_extention="${scriptname##*.}"

        verbose_msg "Setup $script into $HOME/.${file_basename}"
        setup_config "$script" "$HOME/.${file_basename}"
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

    setup_config "${_SCRIPT_PATH}/shell/" "$HOME/.config/shell" || return 1

    return 0
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
        return 0
    fi

    if ! setup_config "$HOME/.vim/init.vim" "$HOME/.vimrc"; then
        error_msg "Vimrc link failed"
        return 1
    fi

    if ! setup_config "$HOME/.vim/ginit.vim" "$HOME/.gvimrc"; then
        error_msg "gvimrc link failed"
        return 1
    fi

    # Windows stuff
    if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then

        # If we couldn't clone our repo, return
        if [[ ! -d "$HOME/vimfiles" ]]; then
            status_msg "Cloning vim dotfiles in $HOME/vimfiles"
            if ! clone_repo "$_URL/.vim" "$HOME/vimfiles"; then
                error_msg "Couldn't get vim repo"
                return 1
            fi
        else
            status_msg "Copying vim dir into in $HOME/vimfiles"
            if ! setup_config "$HOME/.vim" "$HOME/vimfiles"; then
                error_msg "We couldn't copy vim dir"
                return 1
            fi
        fi

        if ! setup_config "$HOME/vimfiles/init.vim" "$HOME/_vimrc"; then
            error_msg "Vimrc link failed"
            return 1
        fi

        if ! setup_config "$HOME/.vim/ginit.vim" "$HOME/_gvimrc"; then
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

    if hash curl 2>/dev/null; then
        verbose_msg "Getting neovim's version with curl"
        local nvim_version="$( curl -sL "https://github.com/neovim/neovim/tags" | grep -oE 'v[0-9]\.[0-9]\.[0-9]$' | sort -u | tail -n 1)"
    elif hash wget 2>/dev/null; then
        verbose_msg "Getting neovim's version with wget"
        local nvim_version="$( wget -qO- "https://github.com/neovim/neovim/tags" | grep -oE 'v[0-9]\.[0-9]\.[0-9]$' | sort -u | tail -n 1)"
    else
        error_msg "Neither Curl nor Wget are available"
    fi

    if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then

        # TODO: auto detect Windows arch and latest nvim version
        if ! hash nvim 2> /dev/null || [[ $_FORCE_INSTALL -eq 1 ]]; then
            if hash curl 2>/dev/null; then
                status_msg "Getting neovim ${nvim_version} executable"
                if ! curl -Ls "https://github.com/neovim/neovim/releases/download/${nvim_version}/nvim-win64.zip" -o "$_TMP/nvim.zip"; then
                    error_msg "Failed neovim download"
                    return 1
                fi

                [[ -d "$HOME/.local/Neovim" ]] && rm -rf "$HOME/.local/Neovim"
                [[ -d "$HOME/.local/neovim" ]] && rm -rf "$HOME/.local/neovim"

                status_msg "Extracting files"
                [[ $_VERBOSE -eq 1 ]] && unzip "$_TMP/nvim.zip" -d "$HOME/.local/"
                [[ $_VERBOSE -eq 0 ]] && unzip -q "$_TMP/nvim.zip" -d "$HOME/.local/"
                # Since neovim dir has a 'bin' folder, it'll be added to the PATH automatically
                mv "$HOME/.local/Neovim" "$HOME/.local/neovim"
            else
                error_msg "Curl is not available"
                return 1
            fi
        fi

        # If we couldn't clone our repo, return
        status_msg "Getting vim dotfiles in $HOME/AppData/Local/nvim"
        if [[ -d "$HOME/.vim" ]]; then
            setup_config "$HOME/.vim" "$HOME/AppData/Local/nvim"
        elif [[ -d "$HOME/vimfiles" ]]; then
            setup_config "$HOME/vimfiles" "$HOME/AppData/Local/nvim"
        else
            clone_repo "$_URL/.vim" "$HOME/AppData/Local/nvim" || return $?
        fi

    else
        # Since no all systems have sudo/root access lets assume all dependencies are
        # already installed; Lets clone neovim in $HOME/.local/neovim and install pip libs
        if ! hash nvim 2> /dev/null || [[ $_FORCE_INSTALL -eq 1 ]]; then
            # Make Neovim only if it's not already installed

            # local force_flag=""
            # if [[ $_FORCE_INSTALL -eq 1 ]]; then
            #     local force_flag="-f"
            # fi

            if hash curl 2>/dev/null; then
                # If the repo was already cloned, lets just build it
                # TODO: Considering to use appimage binary instead of compiling it from the source code
                status_msg "Getting neovim ${nvim_version} executable"
                if curl -Ls "https://github.com/neovim/neovim/releases/download/${nvim_version}/nvim.appimage" -o "$HOME/.local/bin/nvim"; then
                    chmod u+x "$HOME/.local/bin/nvim"
                else
                    error_msg "Curl failed to download Neovim"
                    return 1
                fi
            else
                error_msg "Curl is not available"
                return 1
            fi

            # status_msg "Compiling neovim from source"
            # if [[ -d "$HOME/.local/neovim" ]]; then
            #     "${_SCRIPT_PATH}"/bin/get_nvim.sh -d "$HOME/.local/" -p $force_flag || return $?
            # else
            #     "${_SCRIPT_PATH}"/bin/get_nvim.sh -c -d "$HOME/.local/" -p $force_flag || return $?
            # fi

        fi

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
            status_msg "Cloning vim dotfiles in $HOME/.config/nvim"
            if ! clone_repo "$_URL/.vim" "$HOME/.config/nvim"; then
                error_msg "Fail to clone dotvim files"
                return 1
            fi
        fi

    fi

    # No errors so far
    return 0
}

# TODO: Add GNU global as a windows portable
# TODO: Add compile option to auto compile some programs
function get_portables() {
    local rst=0
    if hash curl 2>/dev/null; then
        status_msg "Checking portable programs"
        if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then

            if ! hash shellcheck 2>/dev/null; then
                status_msg "Getting shellcheck"
                if curl -Ls https://storage.googleapis.com/shellcheck/shellcheck-latest.zip -o "$_TMP/shellcheck-latest.zip"; then
                    [[ -d "$_TMP/shellcheck-latest.zip" ]] && rm -rf "$_TMP/shellcheck-latest.zip"
                    unzip "$_TMP/shellcheck-latest.zip" -d "$_TMP/shellcheck-latest"
                    chmod +x "$_TMP/shellcheck-latest/shellcheck-latest.exe"
                    mv "$_TMP/shellcheck-latest/shellcheck-latest.exe" "$HOME/.local/bin/shellcheck.exe"
                else
                    error_msg "Curl couldn't get shellcheck"
                    rst=1
                fi
            else
                warn_msg "Skipping shellcheck, already installed"
                rst=2
            fi

            if ! hash ctags 2>/dev/null; then
                # TODO: auto detect latest version
                local major="5"
                local minor="8"
                status_msg "Getting ctags"
                curl -Ls "https://downloads.sourceforge.net/project/ctags/ctags/${major}.${minor}/ctags${major}${minor}.zip" -o "$_TMP/ctags${major}${minor}.zip"
                [[ -d "$_TMP/ctags${major}${minor}.zip" ]] && rm -rf "$_TMP/ctags${major}${minor}.zip"
                if ! unzip "$_TMP/ctags${major}${minor}.zip" -d "$_TMP/ctags${major}${minor}"; then
                    error_msg "An error occurred extracting zip file"
                    rst=1
                fi
                chmod +x "$_TMP/ctags${major}${minor}/ctags.exe"
                mv "$_TMP/ctags${major}${minor}/ctags.exe" "$HOME/.local/bin/ctags.exe"
            else
                warn_msg "Skipping ctags, already installed"
                rst=2
            fi
        else
            if hash python 2>/dev/null || hash python2 2>/dev/null || hash python3 2>/dev/null ; then
                if ! hash pip3 2>/dev/null || ! hash pip2 2>/dev/null ; then
                    status_msg "Getting python pip"

                    if curl -Ls https://bootstrap.pypa.io/get-pip.py -o "$_TMP/get-pip.py"; then
                        chmod u+x "$_TMP/get-pip.py"

                        if ! hash pip2 2>/dev/null; then
                            status_msg "Installing pip2"
                            python2 $_TMP/get-pip.py --user
                        fi

                        if ! hash pip3 2>/dev/null; then
                            local python=("8" "7" "6" "5" "4")

                            for version in "${python[@]}"; do
                                if hash "python3.${version}"; then
                                    status_msg "Installing pip3 with python3.${version}"
                                    "python3.${version}" "$_TMP/get-pip.py" --user
                                    break
                                fi
                            done
                        fi
                    else
                        error_msg "Curl couldn't get pip"
                        rst=1
                    fi
                else
                    warn_msg "Skipping pip, already installed"
                    rst=2
                fi
            else
                warn_msg "Skipping pip, the system doesn't have python"
                rst=2
            fi

            if ! hash shellcheck 2>/dev/null; then
                status_msg "Getting shellcheck"
                if curl -Ls https://storage.googleapis.com/shellcheck/shellcheck-latest.linux.x86_64.tar.xz -o "$_TMP/shellcheck.tar.xz"; then
                    pushd "$_TMP" 1> /dev/null || return 1
                    tar xf "$_TMP/shellcheck.tar.xz"
                    chmod u+x "$_TMP/shellcheck-latest/shellcheck"
                    mv "$_TMP/shellcheck-latest/shellcheck" "$HOME/.local/bin/"
                    popd 1> /dev/null || return 1
                else
                    error_msg "Curl couldn't get shellcheck"
                    rst=1
                fi
            else
                warn_msg "Skipping shellcheck, already installed"
                rst=2
            fi

            # if ! hash nvim 2>/dev/null; then
            #     status_msg "Getting Neovim"
            #     curl -Ls https://github.com/neovim/neovim/releases/download/v0.3.0/nvim.appimage -o "$HOME/.local/bin/nvim"
            #     chmod u+x "$HOME/.local/bin/nvim"
            # else
            #     warn_msg "Neovim is already installed"
            # fi

        fi
    else
        error_msg "Curl is not available"
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

    if [[ $_NOCOLOR -eq 1 ]]; then
        local nocolor="--nocolor"
    else
        local nocolor=""
    fi

    if [[ $_FORCE_INSTALL -eq 1 ]]; then
        local force="-force"
    else
        local force=""
    fi

    verbose_msg "Calling get_shell as -> ${_SCRIPT_PATH}/bin/get_shell.sh $force $nocolor -s $_CURRENT_SHELL"
    eval "${_SCRIPT_PATH}/bin/get_shell.sh $force $nocolor -s $_CURRENT_SHELL" || return 1

    return 0
}

function get_dotfiles() {
    _SCRIPT_PATH="$HOME/.local/dotfiles"

    status_msg "Installing dotfiles in $_SCRIPT_PATH"

    [[ ! -d "$HOME/.local/" ]] && mkdir -p "$HOME/.local/"

    clone_repo "$_URL/dotfiles" "$_SCRIPT_PATH" && return 0 || return "$?"
}

function get_cool_fonts() {
    if [[ -z $SSH_CONNECTION ]]; then
        status_msg "Gettings powerline fonts"
        clone_repo "https://github.com/powerline/fonts" "$HOME/.local/fonts"

        if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then
            # We could indeed run $ powershell $HOME/.local/fonts/install.ps1
            # BUT administrator promp will pop up for EVERY font (too fucking much)
            status_msg "Please run $HOME/.local/fonts/install.ps1 inside administrator's powershell"
        else
            status_msg "Installing cool fonts"
            if [[ $_VERBOSE -eq 1 ]]; then
                "$HOME"/.local/fonts/install.sh
            else
                "$HOME"/.local/fonts/install.sh 1> /dev/null
            fi
        fi
    else
        warn_msg "We cannot install cool fonts in a remote session, please run this in you desktop environment"
    fi
    return 0
}

function setup_systemd() {
    if [[ ! $SHELL_PLATFORM == 'MSYS' ]] && [[ ! $SHELL_PLATFORM == 'CYGWIN' ]]; then
        if hash systemctl 2> /dev/null; then
            status_msg "Setting up User's systemd services"
            if [[ -d "$HOME/.config/systemd/user/" ]]; then
                warn_msg "Systemd folder already exist, copying files manually, files won't be auto updated"
                for service in "${_SCRIPT_PATH}"/systemd/*.service; do
                    local servicename="${service##*/}"

                    local file_basename="${servicename%%.*}"
                    # local file_extention="${scriptname##*.}"

                    verbose_msg "Setup $service in $HOME/.config/systemd/user/${servicename}"
                    setup_config "${service}" "$HOME/.config/systemd/user/${servicename}"
                done
            else
                [[ ! -d "$HOME/.config/systemd/" ]] && mkdir -p "$HOME/.config/systemd/"
                setup_config "${_SCRIPT_PATH}/systemd/" "$HOME/.config/systemd/user"
            fi
            status_msg "Please reload user's units with 'systemctl --user daemon-reload'"
            # status_msg "Reloding User's units"
            # systemctl --user daemon-reload
        else
            error_msg "This system doesn't have systemd package"
            return 1
        fi
    else
        error_msg "Systemd's services work just in Linux environment"
        return 1
    fi
    return 0
}

function version() {

    if [[ -f "${_SCRIPT_PATH}/shell/banner" ]]; then
        cat "${_SCRIPT_PATH}/shell/banner"
    elif hash curl 2>/dev/null; then
        curl -Ls https://raw.githubusercontent.com/Mike325/dotfiles/master/shell/banner 2>/dev/null
    fi

    echo ""
    echo "  Mike's install script"
    echo ""
    echo "       Author   : Mike 8a"
    echo "       Version  : ${_VERSION}"
    echo "       Date     : $(date)"
    # echo "       Page     : https://github.com/mike325/dotfiles"
    echo ""
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
        -w|--shell_frameworks)
            _SHELL_FRAMEWORK=1
            _ALL=0
            ;;
        -f|--force)
            _FORCE_INSTALL=1
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
            error_msg "Unknown argument $key"
            help_user
            exit 1
            ;;
    esac
    shift
done

[[ ! -d "$HOME/.local/bin" ]] && verbose_msg "Creating dir $HOME/.local/bin" && mkdir -p "$HOME/.local/bin"
[[ ! -d "$HOME/.local/lib" ]] && verbose_msg "Creating dir $HOME/.local/lib" && mkdir -p "$HOME/.local/lib"
[[ ! -d "$HOME/.config/" ]]   && verbose_msg "Creating dir $HOME/.config/" && mkdir -p "$HOME/.config/"

# Because the "cp -rf" means there are no symbolic links
# we must be sure we wont screw the shell host settings
if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]] || [[ $_CMD == "cp -rf" ]]; then
    verbose_msg "Activating backup"
    _BACKUP=1
fi

if [[ $_BACKUP -eq 1 ]]; then
    status_msg "Preparing backup dir ${_BACKUP_DIR}"
    mkdir -p "${_BACKUP_DIR}"
fi

# If the user request the dotfiles or the script path doesn't have the full files
# (the command may be executed using `curl`)
if [[ $_DOTFILES -eq 1 ]] || [[ ! -d "${_SCRIPT_PATH}/shell" ]]; then
    if get_dotfiles; then
        error_msg "Could not install dotfiles"
        exit 1
    fi
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
verbose_msg "Protocol   : ${_PROTOCOL}"
verbose_msg "User       : ${_GIT_USER}"
verbose_msg "Host       : ${_GIT_HOST}"
if [[ $SHELL_PLATFORM == 'MSYS' ]] || [[ $SHELL_PLATFORM == 'CYGWIN' ]]; then
    verbose_msg "Platform   : Windows"
else
    verbose_msg "Platform   : Linux"
fi

if [[ $_ALL -eq 1 ]]; then
    verbose_msg 'Setting up everything'
    setup_bin
    setup_shell
    setup_shell_framework
    setup_git
    get_portables
    get_vim_dotfiles
    get_nvim_dotfiles
    get_emacs_dotfiles
    get_cool_fonts
    setup_systemd
else
    [[ $_BIN -eq 1 ]] && setup_bin
    [[ $_SHELL -eq 1 ]] && setup_shell
    [[ $_SHELL_FRAMEWORK -eq 1 ]] && setup_shell_framework
    [[ $_GIT -eq 1 ]] && setup_git
    [[ $_PORTABLES -eq 1 ]] && get_portables
    [[ $_VIM -eq 1 ]] && get_vim_dotfiles
    [[ $_NVIM -eq 1 ]] && get_nvim_dotfiles
    [[ $_EMACS -eq 1 ]] && get_emacs_dotfiles
    [[ $_COOL_FONTS -eq 1 ]] && get_cool_fonts
    [[ $_SYSTEMD -eq 1 ]] && setup_systemd
fi

exit 0
