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
_ALIAS=0
_VIM=0
_NVIM=0
_BIN=0
_SHELL_FRAMEWORK=0
_EMACS=0
_DOTFILES=0
_GIT=0
_FORCE_INSTALL=0
_BACKUP=1
_BACKUP_DIR="$HOME/.local/backup_$(date '+%d.%b.%Y_%H-%M-%S')"
_VERBOSE=0
_PORTABLES=0

_NAME="$0"
_NAME="${_NAME##*/}"

_SCRIPT_PATH="$0"

_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

if hash realpath 2>/dev/null; then
    _SCRIPT_PATH=$(realpath "$_SCRIPT_PATH")
else
    pushd "$_SCRIPT_PATH" > /dev/null || exit 1
    _SCRIPT_PATH="$(pwd -P)"
    popd > /dev/null || exit 1
fi

_TMP="/tmp/"

_CMD="ln -s"
_BASE_URL="https://github.com/mike325"

# _DEFAULT_SHELL="${SHELL##*/}"
_CURRENT_SHELL="bash"
_IS_WINDOWS=0

# Windows stuff
if [[ $(uname --all) =~ MINGW ]]; then
    _CURRENT_SHELL="$(ps | grep $(echo $$) | awk '{ print $8 }')"
    _CURRENT_SHELL="${_CURRENT_SHELL##*/}"

    # Horrible hack
    if [[ $_CURRENT_SHELL =~ "ps" ]]; then
        _CURRENT_SHELL="$(ps | tail -n 1 | awk '{ print $8 }')"
        _CURRENT_SHELL="${_CURRENT_SHELL##*/}"
    fi

    # Windows does not support links we will use cp instead
    _IS_WINDOWS=1
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

function help_user() {
    echo ""
    echo "  Simple installer of this dotfiles, by default install (link) all settings and configurations"
    echo "  if any flag ins given, the script will install just want is being told to do."
    echo "      By default command (if none flag is given): $_NAME -s -a -e -v -n -b -g -p"
    echo ""
    echo "  Usage:"
    echo "      $_NAME [OPTIONAL]"
    echo ""
    echo "      Optional Flags"
    echo "          --verbose"
    echo "              Output debug messages"
    echo ""
    echo "          --backup, --backup=DIR"
    echo "              Backup all existing files into $HOME/.local/backup or the provided dir"
    echo "              ----    Backup will be auto activated if windows is running or '-c/--copy' flag is used"
    echo ""
    echo "          -f, --force"
    echo "              Force installation, remove all previous conflict files before installing"
    echo "              This flag is always disable by default"
    echo ""
    echo "          -s, --shell_frameworks"
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
    echo "          -a, --alias"
    echo "              Install:"
    echo "                  - Shell alias in $HOME/.config/shell"
    echo "                  - Shell basic configurations \${SHELL}rc for bash, zsh, tcsh and csh"
    echo "                  - Everything inside ./dotconfigs into $HOME"
    echo "                  - Python startup script in $HOME/.local/lib/"
    echo ""
    echo "          -d, --dotfiles"
    echo "              Download my dotfiles repo in case, this options is meant to be used in case this"
    echo "              script is standalone executed"
    echo "                  URL: https://github.com/mike325/dotfiles"
    echo ""
    echo "          -e, --emacs"
    echo "              Download and install my evil Emacs dotfiles and install systemd's emacs.service"
    echo "                  URL: https://github.com/mike325/.emacs.d"
    echo ""
    echo "          -v, --vim"
    echo "              Download and install my Vim dotfiles"
    echo "                  URL: https://github.com/mike325/.vim"
    echo ""
    echo "          -n, --neovim"
    echo "              Download and install my Vim dotfiles in Neovim's dir."
    echo "              Check if vim dotfiles are already install and copy/link (depends of '-c/copy' flag)"
    echo "              them, otherwise download them from my vim's dotfiles repo"
    echo "                  URL: https://github.com/mike325/.vim"
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
    echo "                  - pip2 and pip3"
    echo "                  - shellcheck"
    echo ""
    echo "          -p, --fonts, --powerline"
    echo "              Install the powerline patched fonts"
    echo "                  * Since the patched fonts have different install method for Windows"
    echo "                    they are just download"
    echo "                  * This options is ignored if the install script is executed in a SSH session"
    echo ""
    echo "          -h, --help"
    echo "              Display help, if you are seeing this, that means that you already know it (nice)"
    echo ""
}

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        echo ""
    fi

    local arg="$1"
    local name="$2"

    local pattern="^--$name[=][a-zA-Z0-9._-/~]+$"

    if [[ ! -z "$3" ]]; then
        local pattern="^--$name[=]$3$"
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
    printf "[!]     ---- Warning!!! %s \n" "$warn_message"
    return 0
}

function error_msg() {
    local error_message="$1"
    printf "[X]     ---- Error!!!   %s \n" "$error_message" 1>&2
    return 0
}

function status_msg() {
    local status_message="$1"
    printf "[*]     ---- %s \n" "$status_message"
    return 0
}

function verbose_msg() {
    if [[ $_VERBOSE -eq 1 ]]; then
        local debug_message="$1"
        printf "[+]     ---- Debug!!!   %s \n" "$debug_message"
    fi
    return 0
}

function execute_cmd() {
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
        rm -rf "$post_cmd"
    elif [[ -f "$post_cmd" ]] || [[ -d "$post_cmd" ]]; then
        warn_msg "Skipping ${post_cmd##*/}, already exists in ${post_cmd%/*}"
        return 1
    fi

    verbose_msg "$_CMD $pre_cmd $post_cmd"

    sh -c "$_CMD $pre_cmd $post_cmd" && return 0 || return "$?"
}

function clone_repo() {
    local repo="$1"
    local dest="$2"

    if hash git 2>/dev/null; then
        if [[ $_BACKUP -eq 1 ]]; then
            if [[ -f "$dest" ]] || [[ -d "$dest" ]]; then
                mv --backup=numbered "$dest" "$_BACKUP_DIR"
            fi
        elif [[ $_FORCE_INSTALL -eq 1 ]]; then
            rm -rf "$dest"
        else
            warn_msg "Skipping ${repo##*/}, already exists in $dest"
            return 1
        fi

        if [[ ! -d "$dest" ]]; then
            verbose_msg "Cloning $repo"
            if git clone --recursive "$repo" "$dest"; then
                return 0
            fi
            return 1
        fi
    else
        error_msg "Git command is not available"
        return 2
    fi
}


function setup_bin() {
    status_msg "Getting shell functions and scripts"

    for script in ${_SCRIPT_PATH}/bin/*; do
        local scriptname="${script##*/}"

        local file_basename="${scriptname%%.*}"
        # local file_extention="${scriptname##*.}"

        execute_cmd "$script" "$HOME/.local/bin/$file_basename"
    done
    return 0
}

function setup_alias() {

    status_msg "Getting python startup script"
    execute_cmd "${_SCRIPT_PATH}/scripts/pythonstartup.py" "$HOME/.local/lib/pythonstartup.py"

    status_msg "Getting dotconfigs"
    for script in ${_SCRIPT_PATH}/dotconfigs/*; do
        local scriptname="${script##*/}"

        local file_basename="${scriptname%%.*}"
        # local file_extention="${scriptname##*.}"

        execute_cmd "$script" "$HOME/.${file_basename}"
    done

    status_msg "Getting Shell init file"
    if [[ $_CURRENT_SHELL =~ bash ]] || [[ $_CURRENT_SHELL =~ zsh ]]; then

        if [[ ! -f "$HOME/.${_CURRENT_SHELL}rc" ]] || [[ $_FORCE_INSTALL -eq 1 ]]; then
            execute_cmd "${_SCRIPT_PATH}/shell/shellrc" "$HOME/.${_CURRENT_SHELL}rc" || return 1
        else
            warn_msg "The file $HOME/.${_CURRENT_SHELL}rc already exists, trying $HOME/.${_CURRENT_SHELL}rc.$USER"
            execute_cmd "${_SCRIPT_PATH}/shell/shellrc" "$HOME/.${_CURRENT_SHELL}rc.$USER" || return 1
        fi
        # execute_cmd "${_SCRIPT_PATH}/shell/${_CURRENT_SHELL}_settings" "$HOME/.config/shell/shell_specific"

        status_msg "Getting shell configs"

        # Since we could fail linking/copying the dir, lets check it first
        execute_cmd "${_SCRIPT_PATH}/shell/" "$HOME/.config/shell" || return 1

        [[ ! -d  "$HOME/.config/shell/host" ]] && mkdir -p  "$HOME/.config/shell/host"

    elif [[ $_CURRENT_SHELL =~ csh ]]; then
        # WARNING !! experimental

        if [[ ! -f "$HOME/.${_CURRENT_SHELL}rc" ]]; then
            execute_cmd "${_SCRIPT_PATH}/shell/shellrc" "$HOME/.${_CURRENT_SHELL}rc" || return 1
        else
            warn_msg "The file $HOME/.${_CURRENT_SHELL}rc already exists, trying $HOME/.${_CURRENT_SHELL}rc.$USER"
            execute_cmd "${_SCRIPT_PATH}/shell/shellrc" "$HOME/.${_CURRENT_SHELL}rc.$USER" || return 1
        fi
        # execute_cmd "${_SCRIPT_PATH}/shell/${_CURRENT_SHELL}_settings" "$HOME/.config/shell/shell_specific"

        status_msg "Getting shell configs"

        # Since we could fail linking/copying the dir, lets check it first
        execute_cmd "${_SCRIPT_PATH}/shell/" "$HOME/.config/shell" || return 1

        [[ ! -d  "$HOME/.config/shell/host" ]] && mkdir -p  "$HOME/.config/shell/host"
    else
        warn_msg "Current shell ( $_CURRENT_SHELL ) is unsupported"
    fi
    return 0
}

function setup_git() {
    status_msg "Installing Global Git settings"
    execute_cmd "${_SCRIPT_PATH}/git/gitconfig" "$HOME/.gitconfig"

    status_msg "Installing Global Git templates and hooks"
    execute_cmd "${_SCRIPT_PATH}/git" "$HOME/.config/git"

    status_msg "Setting up local git commands"
    [[ ! -d "$HOME/.config/git/host" ]] && mkdir -p "$HOME/.config/git/host"

    # Since The current dotfiles may be the first thing to run
    # We want to have the git hooks in here
    status_msg "Settings git hooks for the current dotfiles"
    for hooks in ${_SCRIPT_PATH}/git/templates/hooks/*; do
        local scriptname="${script##*/}"

        local file_basename="${scriptname%%.*}"
        # local file_extention="${scriptname##*.}"

        execute_cmd "$hooks" "${_SCRIPT_PATH}/.git/hooks"
    done
    return 0
}

function get_vim_dotfiles() {
    status_msg "Cloning vim dotfiles in $HOME/.vim"

    # If we couldn't clone our repo, return
    clone_repo "$_BASE_URL/.vim" "$HOME/.vim" || return $?

    execute_cmd "$HOME/.vim/init.vim" "$HOME/.vimrc" || return $?

    execute_cmd "$HOME/.vim/ginit.vim" "$HOME/.gvimrc" || return $?

    # Windows stuff
    if [[ $_IS_WINDOWS -eq 1 ]]; then
        status_msg "Cloning vim dotfiles in $HOME/vimfiles"

        # If we couldn't clone our repo, return
        clone_repo "$_BASE_URL/.vim" "$HOME/vimfiles" || return $?

        execute_cmd "$HOME/vimfiles/init.vim" "$HOME/_vimrc" || return $?

        execute_cmd "$HOME/.vim/ginit.vim" "$HOME/_gvimrc" || return $?
    fi

    # No errors so far
    return 0
}

function get_nvim_dotfiles() {
    # Windows stuff
    status_msg "Setting up neovim"
    if [[ $_IS_WINDOWS -eq 1 ]]; then

        # TODO: auto detect Windows arch and latest nvim version
        if ! hash nvim 2> /dev/null; then
            if hash curl 2>/dev/null; then
                status_msg "Getting neovim executable"
                curl -Ls https://github.com/neovim/neovim/releases/download/v0.2.2/nvim-win64.zip -o "$HOME/.local/nvim.zip"

                [[ -d "$HOME/.local/Neovim" ]] && rm -rf "$HOME/.local/Neovim"
                [[ -d "$HOME/.local/neovim" ]] && rm -rf "$HOME/.local/neovim"

                unzip "$HOME/.local/nvim.zip" -d "$HOME/.local/"
                mv "$HOME/.local/Neovim" "$HOME/.local/neovim"
                # Since neovim dir has a 'bin' folder, it'll be added to the PATH automatically
            fi
        fi

        # If we couldn't clone our repo, return
        status_msg "Cloning vim dotfiles in $HOME/AppData/Local/nvim"
        clone_repo "$_BASE_URL/.vim" "$HOME/AppData/Local/nvim" || return $?
    else
        # Since no all systems have sudo/root access lets assume all dependencies are
        # already installed; Lets clone neovim in $HOME/.local/neovim and install pip libs
        if ! hash nvim 2> /dev/null; then
            # Make Neovim only if it's not already installed

            local force_flag=""
            if [[ $_FORCE_INSTALL -eq 1 ]]; then
                local force_flag="-f"
            fi

            # If the repo was already cloned, lets just build it
            # TODO: Considering to use appimage binary instead of compiling it from the source code
            status_msg "Compiling neovim from source"
            if [[ -d "$HOME/.local/neovim" ]]; then
                "${_SCRIPT_PATH}"/bin/get_nvim.sh -d "$HOME/.local/" -p $force_flag || return $?
            else
                "${_SCRIPT_PATH}"/bin/get_nvim.sh -c -d "$HOME/.local/" -p $force_flag || return $?
            fi
            # If we couldn't clone the repo, return
        fi


        # if the current command creates a symbolic link and we already have some vim
        # settings, lets use them
        status_msg "Checking existing vim dotfiles"
        if [[ "$_CMD" == "ln -s" ]] && [[ -d "$HOME/.vim" ]]; then
            status_msg "Linking current vim dotfiles"
            execute_cmd "$HOME/.vim" "$HOME/.config/nvim"
        else
            status_msg "Cloning vim dotfiles in $HOME/.config/nvim"
            clone_repo "$_BASE_URL/.vim" "$HOME/.config/nvim"
        fi

        (( $? != 0 )) && return $?
    fi

    # No errors so far
    return 0
}

function get_portables() {
    if hash curl 2>/dev/null; then
        status_msg "Checking portable programs"
        if [[ $_IS_WINDOWS -eq 1 ]]; then

            if ! hash shellcheck 2>/dev/null; then
                status_msg "Getting shellcheck"
                if curl -Ls https://storage.googleapis.com/shellcheck/shellcheck-latest.zip -o "$_TMP/shellcheck-latest.zip"; then
                    [[ -d "$_TMP/shellcheck-latest.zip" ]] && rm -rf "$_TMP/shellcheck-latest.zip"
                    unzip "$_TMP/shellcheck-latest.zip" -d "$_TMP/shellcheck-latest"
                    chmod +x "$_TMP/shellcheck-latest/shellcheck-latest.exe"
                    mv "$_TMP/shellcheck-latest/shellcheck-latest.exe" "$HOME/.local/bin/shellcheck.exe"
                else
                    error_msg "Curl couldn't get shellcheck"
                fi
            else
                warn_msg "Skipping shellcheck, already installed"
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
                    return 1
                fi
                chmod +x "$_TMP/ctags${major}${minor}/ctags.exe"
                mv "$_TMP/ctags${major}${minor}/ctags.exe" "$HOME/.local/bin/ctags.exe"
            else
                warn_msg "Skipping ctags, already installed"
            fi



        else
            if ! hash pip3 2>/dev/null || ! hash pip2 2>/dev/null ; then
                status_msg "Getting python pip"
                if curl -Ls https://bootstrap.pypa.io/get-pip.py -o "$_TMP/get-pip.py"; then
                    chmod +x "$_TMP/get-pip.py"
                    ! hash pip2 2>/dev/null || python2 $_TMP/get-pip.py --user
                    ! hash pip3 2>/dev/null || python3 $_TMP/get-pip.py --user
                else
                    error_msg "Curl couldn't get pip"
                fi
            else
                warn_msg "Skipping pip, already installed"
            fi

            if ! hash shellcheck 2>/dev/null; then
                status_msg "Getting shellcheck"
                if curl -Ls https://storage.googleapis.com/shellcheck/shellcheck-latest.linux.x86_64.tar.xz -o "$_TMP/shellcheck.tar.xz"; then
                    pushd "$_TMP" 1> /dev/null || return 1
                    tar xf "$_TMP/shellcheck.tar.xz"
                    chmod +x "$_TMP/shellcheck-latest/shellcheck"
                    mv "$_TMP/shellcheck-latest/shellcheck" "$HOME/.local/bin/"
                    popd 1> /dev/null || return 1
                else
                    error_msg "Curl couldn't get shellcheck"
                fi
            else
                warn_msg "Skipping shellcheck, already installed"
            fi
        fi
        return 0
    fi
    return 1
}


function get_emacs_dotfiles() {
    status_msg "Installing Evil Emacs"

    # If we couldn't clone our repo, return
    clone_repo "$_BASE_URL/.emacs.d" "$HOME/.emacs.d" && return $?

    verbose_msg "Creating dir $HOME/.config/systemd/user" && mkdir -p "$HOME/.config/systemd/user"
    if execute_cmd "${_SCRIPT_PATH}/services/emacs.service" "$HOME/.config/systemd/user/emacs.service"
    then
        return 0
    fi

    return 1
}

function setup_shell_framework() {
    status_msg "Getting shell framework"

    if [[ $_FORCE_INSTALL -eq 1 ]]; then
        "${_SCRIPT_PATH}"/bin/get_shell.sh -s "$_CURRENT_SHELL" -f
    else
        "${_SCRIPT_PATH}"/bin/get_shell.sh -s "$_CURRENT_SHELL"
    fi

    (( $? == 0 )) && return 0 || return "$?"
}

function get_dotfiles() {
    _SCRIPT_PATH="$HOME/.local/dotfiles"

    status_msg "Installing dotfiles in $_SCRIPT_PATH"

    [[ ! -d "$HOME/.local/" ]] && mkdir -p "$HOME/.local/"

    clone_repo "$_BASE_URL/dotfiles" "$_SCRIPT_PATH" && return 0 || return "$?"
}

function get_cool_fonts() {
    if [[ -z $SSH_CONNECTION ]]; then
        status_msg "Gettings powerline fonts"
        clone_repo "https://github.com/powerline/fonts" "$HOME/.local/fonts"

        if [[ $_IS_WINDOWS -eq 1 ]]; then
            # We could indeed run $ powershell $HOME/.local/fonts/install.ps1
            # BUT administrator promp will pop up for EVERY font (too fucking much)
            status_msg "Please run $HOME/.local/fonts/install.ps1 inside administrator's powershell"
        else
            status_msg "Installing cool fonts"
            "$HOME"/.local/fonts/install.sh
        fi
    else
        warn_msg "We cannot install cool fonts in a remote session, please run this in you desktop environment"
    fi
    return 0
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --backup)
            _BACKUP=1
            ;;
        --backup=*)
            if [[ $(__parse_args "$key" "backup") == "$key" ]]; then
                __ERROR_DATA=$(__parse_args "$key" "backup")
                error_msg "Not a valid backupdir $__ERROR_DATA"
                exit 1
            fi
            _BACKUP=1
            _BACKUP_DIR=$(__parse_args "$key" "backup")
            ;;
        -t|--portable|--portables)
            _PORTABLES=1
            _ALL=0
            ;;
        -p|--fonts|--powerline)
            _COOL_FONTS=1
            _ALL=0
            ;;
        -c|--copy)
            _CMD="cp -rf"
            ;;
        -a|--alias)
            _ALIAS=1
            _ALL=0
            ;;
        -s|--shell_frameworks)
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
        *)
            error_msg "Unknown flag $1"
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
if [[ $_IS_WINDOWS -eq 1 ]] || [[ $_CMD == "cp -rf" ]]; then
    verbose_msg "Activating backup"
    _BACKUP=1
fi

if [[ $_BACKUP -eq 1 ]]; then
    status_msg "Preparing backup dir ${_BACKUP_DIR}"
    mkdir -p "${_BACKUP_DIR}"
fi

# If the user request the dotfiles or the script path doesn't have the full files
# (the command may be executed using `curl`)
if [[ $_DOTFILES -eq 1 ]] || [[ ! -f "${_SCRIPT_PATH}/shell/alias" ]]; then
    if get_dotfiles; then
       error_msg "Could not install dotfiles"
       exit 1
    fi
fi

if [[ $_ALL -eq 1 ]]; then
    setup_bin
    setup_alias
    setup_shell_framework
    setup_git
    get_vim_dotfiles
    get_nvim_dotfiles
    get_emacs_dotfiles
    get_cool_fonts
    get_portables
else
    [[ $_BIN -eq 1 ]] && setup_bin
    [[ $_ALIAS -eq 1 ]] && setup_alias
    [[ $_SHELL_FRAMEWORK -eq 1 ]] && setup_shell_framework
    [[ $_GIT -eq 1 ]] && setup_git
    [[ $_VIM -eq 1 ]] && get_vim_dotfiles
    [[ $_NVIM -eq 1 ]] && get_nvim_dotfiles
    [[ $_EMACS -eq 1 ]] && get_emacs_dotfiles
    [[ $_COOL_FONTS -eq 1 ]] && get_cool_fonts
    [[ $_PORTABLES -eq 1 ]] && get_portables
fi

exit 0
