#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1090

# Author: Mike 8a
# Description: Some useful alias and functions
# github.com/mike325/dotfiles

################################################################################
#                          Set the default text editor                         #
################################################################################

! hash is_wsl 2>/dev/null && is_wsl() { return 0; }
! hash is_windows 2>/dev/null && is_windows() { return 0; }

if hash vim 2> /dev/null || hash nvim 2>/dev/null; then
    if hash nvim 2>/dev/null; then

        [[ ! -d "$HOME/.cache/nvim" ]] && mkdir -p "$HOME/.cache/nvim"
        export NVIM_LISTEN_ADDRESS="$HOME/.cache/nvim/socket"

        if is_windows && ! is_wsl; then
            alias cdvi="cd ~/.vim"
            alias cdvim="cd ~/AppData/Local/nvim/"
            # NOTE: This is set inside Neovim settings
            if [[ -z "$NVIM_LISTEN_ADDRESS" ]] || ! hash nvr 2>/dev/null; then
                export EDITOR="vim"
                alias vi="vim --cmd 'let g:minimal=1'"
                alias viu="vim -u NONE"
                # Fucking typos
                alias nvi="nvim"
                alias vnim="nvim"
            else
                # export MANPAGER="nvr -c 'Man!' --remote -"
                export GIT_PAGER="nvr -cc 'setlocal modifiable' -c 'setlocal ft=git  nomodifiable' --remote -"
                export EDITOR="nvr --remote-wait"
                alias vi="nvr --remote-silent"
                alias vim="nvr --remote-silent"
                alias nvi="nvr --remote-silent"
                alias nvim="nvr --remote-silent"
                alias vnim="nvr --remote-silent"
            fi

        else
            alias cdvi="cd ~/.vim"
            alias cdvim="cd ~/.config/nvim"

            _nvim="$(which nvim)"

            # export MANPAGER="$_nvim --cmd 'let g:minimal=1' +Man!"
            export EDITOR="nvim"

            # Fucking typos
            alias nvi="nvim"
            alias vnim="nvim"

            # # TODO:  Need to improve this to make it tmux pane aware
            # function nvim() {
            #     if hash nvr 2>/dev/null && [[ -e  "$HOME/.cache/nvim/socket" ]]; then
            #         local args=()
            #         local avoid=0
            #         for arg in "$@"; do
            #             case "$arg" in
            #                 -*|+*)
            #                     if [[ "$arg" == '--cmd' ]]; then
            #                         local avoid=1
            #                     else
            #                         local avoid=0
            #                     fi
            #                     ;;
            #                 *)
            #                     if [[ $avoid -eq 0 ]]; then
            #                         args+=("$arg")
            #                     fi
            #                     [[ $avoid -eq 1 ]] && local avoid=0
            #                     ;;
            #             esac
            #         done
            #         nvr --servername "$HOME/.cache/nvim/socket" --remote-silent "${args[@]}"
            #     else
            #         $_nvim --listen "$HOME/.cache/nvim/socket" $@
            #     fi
            # }

            if hash rshell 2>/dev/null; then
                if hash nvr 2>/dev/null; then
                    export RSHELL_EDITOR="nvr --servername $HOME/.cache/nvim/socket --remote-wait"
                else
                    export RSHELL_EDITOR="$EDITOR"
                fi
            fi

            if hash nvr 2>/dev/null && [[ -e  "$HOME/.cache/nvim/socket" ]]; then
                alias vi="nvr --servername $HOME/.cache/nvim/socket --remote-silent"
            else
                alias vi="nvim --cmd 'let g:minimal=1'"
            fi

        fi
    else
        alias cdvim="cd ~/.vim"
        alias cdvi="cd ~/.vim"
        # export MANPAGER="env MAN_PN=1 vim --cmd 'let g:minimal=1 --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=man  nomodifiable' +MANPAGER -"
        export EDITOR="vim"

        alias vi="vim --cmd 'let g:minimal=1'"
        alias viu="vim -u NONE"
    fi
fi

if hash delta 2>/dev/null; then
    export GIT_PAGER="delta --dark --24-bit-color auto"
elif hash bat 2>/dev/null; then
    export GIT_PAGER="bat"
fi

################################################################################
#                          Fix my common typos                                 #
################################################################################

alias gti="git"
alias got="git"
alias gut="git"
alias gi="git"

if hash bat 2>/dev/null; then
    alias cat="bat"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"

fi

if is_windows; then
    alias bim="vim"
    alias cim="vim"
    alias im="vim"
elif hash nvim 2>/dev/null; then
    alias bim="nvim"
    alias cim="nvim"
    alias im="nvim"
else
    alias bim="vim"
    alias cim="vim"
    alias im="vim"
fi

alias bi="vi"
alias ci="vi"

alias py="python"
alias py2="python2"
alias py3="python3"

################################################################################
#                        Some useful shortcuts                                 #
################################################################################

alias sshkey='ssh-keygen -t rsa -b 4096 -C "${EMAIL:-mickiller.25@gmail.com}"'

alias user="whoami"
alias j="jobs"

# Check all user process
alias psu='ps -u $USER'

# alias q="exit"
alias cl="clear"
if [[ $EUID -ne 0 ]]; then
    alias turnoff="sudo poweroff"
else
    alias turnoff="poweroff"
fi

if hash clenaswap 2>/dev/null; then
    alias cw="clenaswap"
fi

# Show used ports
alias ports="netstat -tulpn"

if [[ -f /sys/fs/cgroup/memory/memory.swappiness ]]; then
    alias swappiness='cat /sys/fs/cgroup/memory/memory.swappiness'
elif [[ -f /proc/sys/vm/swappiness ]]; then
    alias swappiness='cat /proc/sys/vm/swappiness'
fi

# Termux's grep doesn't have color support
if [[ $(uname --all) =~ Android ]]; then
    unalias grep > /dev/null
    alias grep="grep -n"
else
    alias grep="grep --color=auto -n"
fi

alias grepo="grep -o"
alias grepe="grep -E"

alias ls='ls --color --classify --human-readable'
alias l="ls"
alias la="ls -A"
alias ll="ls -l"
alias lla="ls -lA"

alias lat="ls -A --sort=time"
alias llt="ls -l --sort=time"
alias llat="ls -lA --sort=time"

alias las="ls -A --sort=size"
alias lls="ls -l --sort=size"
alias llas="ls -lA --sort=size"

# default fd package in debian is fd-find, so we add a small alias to us fd
if hash fdfind 2>/dev/null && ! hash fd 2>/dev/null; then
    alias fd=fdfind
fi

# We only want sudo alias when user =! root
[[ $EUID -ne 0 ]] && alias sudo='sudo '

# Magnificent app which corrects your previous console command
# https://github.com/nvbn/thefuck
if hash thefuck 2>/dev/null; then
    # eval "$(thefuck --alias fuck --enable-experimental-instant-mode)"

    eval "$(thefuck --alias)"
    alias please='fuck'

    alias crap="eval \$(thefuck --alias); echo 'f*cks ready'"

    # Yep tons of fucks
    alias guck='fuck'
    alias fukc='fuck'
    alias gukc='fuck'
    alias fuvk='fuck'
else
    :
    # alias fuck='sudo $(history -p \!\!)'
fi

if hash ntfy 2>/dev/null; then

    if [[ -z $_NO_NTFY ]]; then
        # VCS
        export AUTO_NTFY_DONE_IGNORE="git hg svn"
        # Editors
        export AUTO_NTFY_DONE_IGNORE="nvim vi vim emacs sudoedit $AUTO_NTFY_DONE_IGNORE"
        # Readers
        export AUTO_NTFY_DONE_IGNORE="cat bat less more man watch $AUTO_NTFY_DONE_IGNORE"
        # Typos
        export AUTO_NTFY_DONE_IGNORE="bim cim im bi ci nvi vnim gti got gut gi guck fukc gukc please fuvk $AUTO_NTFY_DONE_IGNORE"
        # alias
        export AUTO_NTFY_DONE_IGNORE="tma tmn tms py py3 py2 cl nvi del usage vimv extract ports searchpkg fe fkill fssh $AUTO_NTFY_DONE_IGNORE"
        # GUI
        export AUTO_NTFY_DONE_IGNORE="nautilus gonvim firefox vlc $AUTO_NTFY_DONE_IGNORE"
        # Misc
        export AUTO_NTFY_DONE_IGNORE="dmesg rshell tmux screen meld ytop htop top ssh fg cd fzf clear ctags fuck $AUTO_NTFY_DONE_IGNORE"
        # CLI tools
        export AUTO_NTFY_DONE_IGNORE="speedtest speedtest-clie $AUTO_NTFY_DONE_IGNORE"
        eval "$(ntfy shell-integration)"
    fi

    if hash xclip 2>/dev/null; then
        alias clipsend='ntfy send "$(xclip -o)"'
    fi
fi

if hash cleanswap 2>/dev/null; then
    alias cw="cleanswap"
fi

# load kernel module for virtualbox
if [[ $EUID -ne 0 ]]; then
    alias vbk="sudo modprobe vboxdrv"
else
    alias vbk="modprobe vboxdrv"
fi

if hash ctags 2>/dev/null; then
    # Get Fucking Tags
    alias gft="ctags -R ."
fi

if hash fzf 2>/dev/null; then
    if hash git 2>/dev/null; then
        if hash fd 2>/dev/null; then
            export FZF_DEFAULT_COMMAND="(git --no-pager ls-files -co --exclude-standard || fd --ignore-file ~/.config/git/ignore --type f --hidden --follow --color always -E '*.spl' -E '*.aux' -E '*.out' -E '*.o' -E '*.pyc' -E '*.gz' -E '*.pdf' -E '*.sw' -E '*.swp' -E '*.swap' -E '*.com' -E '*.exe' -E '*.so' -E '*/cache/*' -E '*/__pycache__/*' -E '*/tmp/*' -E '.git/*' -E '.svn/*' -E '.xml' -E '*.bin' -E '*.7z' -E '*.dmg' -E '*.gz' -E '*.iso' -E '*.jar' -E '*.rar' -E '*.tar' -E '*.zip' -E 'TAGS' -E 'tags' -E 'GTAGS' -E 'COMMIT_EDITMSG' . . ) 2> /dev/null"
            export FZF_ALT_C_COMMAND="fd --ignore-file ~/.config/git/ignore --color always -t d . $HOME 2>/dev/null"
        elif hash rg 2>/dev/null; then
            export FZF_DEFAULT_COMMAND='(git --no-pager ls-files -co --exclude-standard || rg --line-number --column --with-filename --color always --no-search-zip --hidden --trim --files . ) 2> /dev/null'
        elif hash ag 2>/dev/null; then
            export FZF_DEFAULT_COMMAND='(git --no-pager ls-files -co --exclude-standard || ag -l --follow --color --nogroup --hidden -g "" ) 2> /dev/null'
        else
            export FZF_DEFAULT_COMMAND="(git --no-pager ls-files -co --exclude-standard || find . -regextype egrep -type f -iname '*' ! \( -iregex '.*\.(pyc|o|out|spl|gz|sw|swo|swp|pdf|tar|zip)' -or -path '*/.git/*' -or -path '*/__pycache__/*' \)) 2> /dev/null"
        fi
    else
        if hash fd 2>/dev/null; then
            export FZF_DEFAULT_COMMAND="fd --ignore-file ~/.config/git/ignore --type f --hidden --follow --color always -E '*.spl' -E '*.aux' -E '*.out' -E '*.o' -E '*.pyc' -E '*.gz' -E '*.pdf' -E '*.sw' -E '*.swp' -E '*.swap' -E '*.com' -E '*.exe' -E '*.so' -E '*/cache/*' -E '*/__pycache__/*' -E '*/tmp/*' -E '.git/*' -E '.svn/*' -E '.xml' -E '*.bin' -E '*.7z' -E '*.dmg' -E '*.gz' -E '*.iso' -E '*.jar' -E '*.rar' -E '*.tar' -E '*.zip' -E 'TAGS' -E 'tags' -E 'GTAGS' -E 'COMMIT_EDITMSG' . . 2> /dev/null"
            export FZF_ALT_C_COMMAND="fd --ignore-file ~/.config/git/ignore --color always -t d . $HOME"
        elif hash rg 2>/dev/null; then
            export FZF_DEFAULT_COMMAND='rg --line-number --column --with-filename --color always --no-search-zip --hidden --trim --files . 2> /dev/null'
        elif hash ag 2>/dev/null; then
            export FZF_DEFAULT_COMMAND='ag -l --follow --color --nogroup --hidden -g "" 2> /dev/null'
        else
            export FZF_DEFAULT_COMMAND="find . -regextype egrep -type f -iname '*' ! \( -iregex '.*\.(pyc|o|out|spl|gz|sw|swo|swp|pdf|tar|zip)' -or -path '*/.git/*' -or -path '*/__pycache__/*' \) 2>/dev/ull"
        fi
    fi

    if [[ -n "$FZF_DEFAULT_COMMAND" ]]; then
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    export FZF_CTRL_R_OPTS='--sort'

    export FZF_DEFAULT_OPTS='--layout=reverse --border --ansi'

    if ! is_windows; then
        export FZF_DEFAULT_OPTS="--height 70% $FZF_DEFAULT_OPTS"
    fi

    export FZF_COMPLETION_TRIGGER='**'

    # Options to fzf command
    export FZF_COMPLETION_OPTS='+c -x'

    # fkill - kill processes - list only the ones you can kill. Modified the earlier script.
    fkill() {
        local pid
        if [ "$UID" != "0" ]; then
            pid=$(ps -f -u $UID | sed 1d | fzf --multi --exit-0 | awk '{print $2}')
        else
            pid=$(ps -ef | sed 1d | fzf --multi --exit-0 | awk '{print $2}')
        fi

        if [ "x$pid" != "x" ]; then
            echo "$pid" | xargs kill "-${1:-7}"
        fi
    }

    if  hash ssh 2>/dev/null && [[ -f "$HOME/.ssh/config" ]]; then
        fssh() {
            # shellcheck disable=SC2155
            local host=$(grep -Ei '^Host\s+[a-zA-Z0-9]+' "$HOME/.ssh/config" | awk '{print $2}' | fzf)
            if [[ -n "$host" ]]; then
                ssh "$host"
            fi
        }
    fi

fi

################################################################################
#                               Git shortcut                                   #
################################################################################

if hash git 2>/dev/null; then
    alias clone="git clone"
    alias ga="git add"
    alias gs="git status"
    alias gc="git commit"
    alias gps="git push"
    alias gpl="git pull"
    alias gco="git checkout "
    alias gr="git reset"
    alias gss="git stash save"
    alias gsp="git stash pop"
    alias gsd="git stash drop"
    alias gsa="git stash apply"
    alias gsl="git stash list"
    alias gsw="git stash show"
fi

################################################################################
#                         Package management shortcuts                         #
################################################################################
# TODO Make a small function to install system basics

# if hash docker 2>/dev/null; then
#     if [[ $EUID -ne 0 ]] && [[ ! "$(groups)" =~ .*docker.* ]]; then
#         alias docker="sudo docker"
#         alias docker-compose="sudo docker-compose"
#     fi
#     alias dkpa="docker ps -a"
# fi

# Yeah I'm too lazy to remember each command in every distro soooooo
# I added this alias
# TODO add other distros commands I've used, like Solus
pkg=""
if hash yaourt 2>/dev/null|| hash yay 2>/dev/null || hash pacman 2>/dev/null; then
    # 'Install' package maybe in the PATH

    if hash yay 2>/dev/null; then
        pkg="yay"
    elif hash yaourt 2>/dev/null; then
        pkg="yaourt"
    elif hash pacman 2>/dev/null; then
        pkg="pacman"
    fi

    if ! hash fzf 2>/dev/null; then
        alias searchpkg="${pkg} -Ss"
    else
        function searchpkg() {
            if hash yay 2>/dev/null; then
                local pkg="yay"
            elif hash yaourt 2>/dev/null; then
                local pkg="yaourt"
            elif hash pacman 2>/dev/null; then
                local pkg="pacman"
            fi
            # shellcheck disable=SC2155
            local name=$( ${pkg} -Ss "$@" | fzf)
            if [[ -n "$name" ]]; then
                echo "$name"
            fi
        }
    fi

    alias cleanpkg="${pkg} -Sc"

    alias rmpkg="${pkg} -Rns"

    if hash yay 2>/dev/null || hash yaourt 2>/dev/null; then
        if ! hash getpkg 2>/dev/null; then
            function getpkg() {
                if hash yay 2>/dev/null; then
                    local pkg="yay"
                elif hash yaourt 2>/dev/null; then
                    local pkg="yaourt"
                fi

                sh -c "${pkg} -S $*"
            }
        fi

        function update() {
            if hash yay 2>/dev/null; then
                local pkg="yay"
            elif hash yaourt 2>/dev/null; then
                local pkg="yaourt"
            fi

            if [[ -z "$1" ]]; then
                 sh -c "${pkg} -Syu --repo --noconfirm"
             else
                 sh -c "${pkg} -Syu $*"
            fi
        }
        # alias update="${pkg} -Syu" && alias updaten="${pkg} -Syu --noconfirm"
    fi

    if [[ $EUID -ne 0 ]] && { ! hash yaourt 2>/dev/null && ! hash yay 2>/dev/null; }; then
        unalias getpkg 2>/dev/null
        unalias getpkgn 2>/dev/null

        alias update="sudo ${pkg} -Syu"
        alias updaten="sudo ${pkg} -Syu --noconfirm"
        alias getpkgn="${pkg} -S --noconfirm"

        if ! hash getpkg 2>/dev/null; then
            alias getpkg="sudo ${pkg} -S"
        fi

        unalias rmpkg && alias rmpkg="sudo ${pkg} -Rns"

        unalias cleanpkg && alias cleanpkg="sudo ${pkg} -S"
    fi

elif hash apt-get 2>/dev/null || hash apt 2>/dev/null; then

    if hash apt 2>/dev/null; then
        pkg="apt"
    elif hash apt-get 2>/dev/null; then
        pkg="apt-get"
    fi

    if ! hash fzf 2>/dev/null; then
        alias searchpkg="apt-cache search"
    else
        function searchpkg() {
            if hash apt 2>/dev/null; then
                local pkg="apt"
            elif hash apt-get 2>/dev/null; then
                local pkg="apt-get"
            fi
            # shellcheck disable=SC2155
            local name=$(apt-cache search "$@" | fzf)
            if [[ -n "$name" ]]; then
                echo "$name"
            fi
        }
    fi

    if [[ $EUID -ne 0 ]]; then
        if ! hash getpkg 2>/dev/null; then
            alias getpkg="sudo ${pkg} install"
        fi
        alias getpkgn="sudo ${pkg} install -y"

        alias update="sudo ${pkg} update && sudo ${pkg} upgrade"
        alias updaten="sudo ${pkg} update && sudo ${pkg} upgrade -y"

        alias rmpkg="sudo ${pkg} remove"
    else
        if ! hash getpkg 2>/dev/null; then
            alias getpkg="${pkg} install"
        fi
        alias getpkgn="${pkg} install -y"

        alias update="${pkg} update && ${pkg} upgrade"
        alias updaten="${pkg} update && ${pkg} upgrade -y"

        alias rmpkg="${pkg} remove"
    fi

elif hash dnf 2>/dev/null || hash yum 2>/dev/null ; then

    if hash dnf 2>/dev/null; then
        pkg="dnf"
    elif hash yum 2>/dev/null; then
        pkg="yum"
    fi

    if ! hash fzf 2>/dev/null; then
        alias searchpkg="${pkg} search"
    else
        function searchpkg() {
            if hash dnf 2>/dev/null; then
                local pkg="dnf"
            elif hash yum 2>/dev/null; then
                local pkg="yum"
            fi
            # shellcheck disable=SC2155
            local name=$( ${pkg} search "$@" | fzf)
            if [[ -n "$name" ]]; then
                echo "$name"
            fi
        }
    fi

    if [[ $EUID -ne 0 ]]; then
        if ! hash getpkg 2>/dev/null; then
            alias getpkg="sudo ${pkg} install"
        fi
        alias getpkgn="sudo ${pkg} -y install"

        alias update="sudo ${pkg} update"
        alias updaten="sudo ${pkg} update -y"

        alias rmpkg="sudo ${pkg} remove"
    else
        if ! hash getpkg 2>/dev/null; then
            alias getpkg="${pkg} install"
        fi
        alias getpkgn="${pkg} -y install"

        alias update="${pkg} update"
        alias updaten="${pkg} update -y"

        alias rmpkg="${pkg} remove"
    fi
fi

unset pkg

################################################################################
#               Functions to move around dirs and other simple stuff           #
################################################################################

# TODO: Move this crap to ${SHELL}.logout
function killssh() {
    if hash pgrep 2>/dev/null; then
        if [[ -n $(pgrep -u "$USER" ssh-agent) ]]; then
            # shellcheck disable=SC2046
            kill -7 $(pgrep -u "$USER" ssh-agent)
        fi
    fi
    return 0
}

function ssha() {
    eval "$(ssh-agent)"
    ssh-add ~/.ssh/id_rsa
    return 0
}

# Simple map of "q" to deactivate virtualenv or exit terminal session
function q() {
    if hash deactivate 2> /dev/null || [[ -n $VIRTUAL_ENV ]]; then
        deactivate
    else
        exit
    fi
}

function venv() {
    local _name=("env" "venv" ".env" ".venv")
    local _top=""
    local _success=0
    local _nogit=0

    while [[ $# -gt 0 ]]; do
        local key="$1"
        case "$key" in
            -h|--help)
                echo ""
                echo "  Source given virtualevn"
                echo ""
                echo "  Usage:"
                echo "      venv [OPTIONAL]"
                echo "          Ex."
                echo "          $ venv -g"
                echo "          $ venv -g django"
                echo "          $ venv ~/django"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit."
                echo ""
                return 0
                ;;
            -n|--name)
                _name=("$2")
                _nogit=1
                shift
                ;;
            *)
                ;;
        esac
        shift
    done

    if [[ $_nogit -eq 0 ]]; then
        if git rev-parse --show-toplevel &>/dev/null; then
            _top="$(git rev-parse --show-toplevel)"
            _git_dir="$(git rev-parse --git-dir)"

            for i in "${_name[@]}"; do
                _name+=("$_top/$i")
                _name+=("$_git_dir/$i")
            done
        fi
    fi

    for i in "${_name[@]}"; do
        if [[ -f "$i/bin/activate" ]]; then
            # shellcheck disable=SC1091
            source "$i/bin/activate"
            _success=1
            break
        fi
    done

    if [[ $_success -eq 1 ]]; then
        return 0
    fi

    return 1
}

alias vven="venv"
alias vnev="venv"
alias vevn="venv"

function bk() {
    for key in "$@"; do
        case "$key" in
            -h|--help)

                echo ""
                echo "  Function to go back any number of dirs"
                echo ""
                echo "  Usage:"
                echo "      $ bk [Number of nodes to move back] [OPTIONAL]"
                echo "          Ex."
                echo "          $ bk 2 # = cd ../../"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit. If you are seeing this,"
                echo "              that means that you already know it (nice)"
                echo ""

                return 0
                ;;
        esac
    done

    if [[ -n "$1" ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
        local parent="./"
        for (( i = 0; i < $1; i++ )); do
            local parent="${parent}../"
        done
        cd "$parent" || return 1
    elif [[ -z "$1" ]]; then
        cd ..
    else
        echo "  ---- [X] Error Unexpected arg $1, please provide a number" 1>&2
        return 1
    fi

    return 0
}

function mkcd() {
    for key in "$@"; do
        case "$key" in
            -h|--help)

                echo ""
                echo "  Create a dir an move to it"
                echo ""
                echo "  Usage:"
                echo "      mkcd NEW_DIR [OPTIONAL]"
                echo "          Ex."
                echo "          $ mkcd new_foo"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit."
                echo ""

                return 0
                ;;
        esac
    done

    if [[ -n "$1" ]]; then
        mkdir -p "$1"
        cd "$1" || return 1
        return 0
    fi
    return 1
}

function llg() {
    if [[ -n "$1" ]]; then
        # shellcheck disable=SC2010
        ls -lhA | grep "$@"
    fi
}

function rl() {
    rm -f "$@" ./*.log
    return 0
}

# Init original path with HOME dir
ORIGINAL_PATH="$(pwd)"

# Move to the realpath version of the curren working dir
function crp() {
    # Save the current path
    ORIGINAL_PATH="$(pwd)"
    cd "$(grp)" || return 1
}

# Go back to the last sym path or $HOME
function gobk() {
    cd "$ORIGINAL_PATH" || return 1
}

# Go relative path
# alias grp="gobk"

# Check what's in the trash can
function cdt() {
    if [[ -d /tmp/.trash ]]; then
        pushd /tmp/.trash 1> /dev/null || exit 1
    fi
    return 0
}

# TODO: Make full pattern substitution to change any node of the string
function replace_base() {
    local cwd
    local new_cwd
    for key in "$@"; do
        case "$key" in
            -h|--help)

                echo ""
                echo "  Function to look for the nearest ancestor with the full given path"
                echo ""
                echo "  Usage:"
                echo "      $ replace_base DIR [OPTIONAL]"
                echo "          Ex."
                echo "          /home/$USER/foo/dummy $ replace_base bar"
                echo "          /home/$USER/bar/dummy $"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit. If you are seeing this,"
                echo "              that means that you already know it (nice)"
                echo ""

                return 0
                ;;
        esac
    done

    if [[ -z "$1" ]]; then
        echo "  ---- [X] Error Unexpected arg $1, please provide a number" 1>&2
        return 1
    fi

    new_cwd="$1"
    cwd="$(pwd)"

    local new_path=""

    local array_list
    # shellcheck disable=SC2207
    array_list=($( pwd | tr '/' "\n"))

    for i in "${array_list[@]}"; do
        new_path="${cwd/$i/$new_cwd}"
        if [[ -d "$new_path" ]] && [[ "$new_path" != "$(pwd)" ]]; then
            if ! pushd "$new_path" 1> /dev/null; then
                return 1
            fi
            return 0
        fi
        new_path=""
    done

    echo "  ---- [X] Error $new_cwd is not a parent relative dir" 1>&2
    return 1
}

alias rb="replace_base"

function change_base() {
    local cwd
    local new_cwd
    for key in "$@"; do
        case "$key" in
            -h|--help)

                echo ""
                echo "  Function to look for the nearest ancestor of given dir"
                echo ""
                echo "  Usage:"
                echo "      $ change_base DIR [OPTIONAL]"
                echo "          Ex."
                echo "          /home/$USER/foo $ change_base bar"
                echo "          /home/$USER/bar $"
                echo ""
                echo "      Optional Flags"
                echo "          -h, --help"
                echo "              Display help and exit. If you are seeing this,"
                echo "              that means that you already know it (nice)"
                echo ""

                return 0
                ;;
        esac
    done

    if [[ -z "$1" ]]; then
        echo "  ---- [X] Error Unexpected arg $1, please provide a number" 1>&2
        return 1
    fi

    cwd="$(pwd)"
    new_cwd="$1"

    local new_path=""

    while [[ $cwd != "" ]]; do
        local cwd="${cwd%/*}"
        local new_path="$cwd/$new_cwd"

        if [[ -d  "$new_path" ]] && [[ "$new_path" != "$(pwd)" ]]; then
            if ! pushd "$new_path" 1> /dev/null; then
                return 1
            fi
            return 0
        fi
    done

    echo "  ---- [X] Error $1 is not a parent relative dir" 1>&2
    return 1
}

alias cb="change_base"


if hash emacs 2>/dev/null; then
    function cmacs() {
        emacsclient -nw "$@"
    }

    function gmacs() {
        emacsclient -c "$@" &
    }

    function dmacs() {
        emacs --daemon &
    }

    function kmacs() {
        emacsclient -e "(kill-emacs)"
    }
fi

if hash tmux 2>/dev/null; then
    alias tma='tmux a'
    alias tms='tmux new -s main'
    alias tmn='tmux new '
fi

if hash ffprobe 2>/dev/null; then
    function media_info() {
        local filename="$1"

        if [[ -n "$2" ]]; then
            ffprobe -v quiet -show_format -show_streams -hide_banner -print_format "$2" -i "$filename"
        else
            ffprobe -v quiet -show_format -show_streams -hide_banner -i "$filename"
        fi
    }
fi

#######################################################################
#                          Global Variables                           #
#######################################################################

export DOTNET_CLI_TELEMETRY_OPTOUT=1
export EMAIL='mickiller.25@gmail.com'

[[ -z $GIT_USER ]] && export GIT_USER='Mike'
[[ -z $GIT_MAIL ]] && export GIT_MAIL='mickiller.25@gmail.com'

if hash mqttwarn 2>/dev/null && [[ -f  "$HOME/.config/mqttwarn/mqttwarn.ini" ]] && [[ -z $MQTTWARNINI ]] ; then
    export MQTTWARNINI="$HOME/.config/mqttwarn/mqttwarn.ini"
fi

if is_windows; then
    export CYGWIN=winsymlinks:native
fi
