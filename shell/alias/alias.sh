#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1090

################################################################################
#                                                                              #
#   Author: Mike 8a                                                            #
#   Description: Some useful alias and functions                               #
#                                                                              #
#                                     -`                                       #
#                     ...            .o+`                                      #
#                  .+++s+   .h`.    `ooo/                                      #
#                 `+++%++  .h+++   `+oooo:                                     #
#                 +++o+++ .hhs++. `+oooooo:                                    #
#                 +s%%so%.hohhoo'  'oooooo+:                                   #
#                 `+ooohs+h+sh++`/:  ++oooo+:                                  #
#                  hh+o+hoso+h+`/++++.+++++++:                                 #
#                   `+h+++h.+ `/++++++++++++++:                                #
#                            `/+++ooooooooooooo/`                              #
#                           ./ooosssso++osssssso+`                             #
#                          .oossssso-````/osssss::`                            #
#                         -osssssso.      :ssss``to.                           #
#                        :osssssss/  Mike  osssl   +                           #
#                       /ossssssss/   8a   +sssslb                             #
#                     `/ossssso+/:-        -:/+ossss'.-                        #
#                    `+sso+:-`                 `.-/+oso:                       #
#                   `++:.                           `-/+/                      #
#                   .`   github.com/mike325/dotfiles   `/                      #
#                                                                              #
################################################################################

################################################################################
#                          Set the default text editor                         #
################################################################################

# Set vi to start as a minimal setup with just settings, mappings and autocmd; 0 plugins

if hash vim 2> /dev/null || hash nvim 2>/dev/null; then
    if hash nvim 2>/dev/null; then
        if is_windows; then
            alias cdvi="cd ~/.vim"
            alias cdvim="cd ~/AppData/Local/nvim/"
            # NOTE: This is set inside Neovim settings
            if [[ -z "$NVIM_LISTEN_ADDRESS" ]] && hash nvr 2>/dev/null; then
                function nvim() {
                    # NOTE: This is set inside Neovim settings
                    if [[ -z "$NVIM_LISTEN_ADDRESS" ]]; then
                        nvim-qt "$@" &
                    else
                        nvim "$@"
                    fi
                }
                export MANPAGER="env MAN_PN=1 vim --cmd 'let g:minimal=1 --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=man  nomodifiable' +MANPAGER -"
                export GIT_PAGER="vim --cmd 'let g:minimal=1' --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=git  nomodifiable' -"
                export EDITOR="vim"
                alias vi="vim --cmd 'let g:minimal=1'"
                alias viu="vim -u NONE"
                # Fucking typos
                alias nvi="nvim"
                alias vnim="nvim"
            else
                export MANPAGER="nvr -cc 'setlocal modifiable' -c 'silent! setlocal  nomodifiable ft=man' --remote -"
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
            # NOTE: This is set inside Neovim settings
            if [[ -z "$NVIM_LISTEN_ADDRESS" ]]; then
                export MANPAGER="nvim --cmd 'let g:minimal=1' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal  nomodifiable ft=man' -"
                export GIT_PAGER="nvim --cmd 'let g:minimal=1' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal ft=git  nomodifiable' - "
                export EDITOR="nvim"
                alias vi="nvim --cmd 'let g:minimal=1'"
                alias viu="nvim -u NONE"
                # Fucking typos
                alias nvi="nvim"
                alias vnim="nvim"
            else
                export MANPAGER="nvr -cc 'setlocal modifiable' -c 'silent! setlocal  nomodifiable ft=man' --remote-tab -"
                export GIT_PAGER="nvr -cc 'setlocal modifiable' -c 'setlocal ft=git  nomodifiable' --remote-tab -"
                export EDITOR="nvr --remote-tab-wait"
                alias vi="nvr --remote-silent"
                alias vim="nvr --remote-silent"
                alias nvi="nvr --remote-silent"
                alias nvim="nvr --remote-silent"
                alias vnim="nvr --remote-silent"
            fi
        fi
    else
        alias cdvim="cd ~/.vim"
        alias cdvi="cd ~/.vim"
        export MANPAGER="env MAN_PN=1 vim --cmd 'let g:minimal=1 --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=man  nomodifiable' +MANPAGER -"
        export GIT_PAGER="vim --cmd 'let g:minimal=1' --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=git  nomodifiable' -"
        export EDITOR="vim"

        alias vi="vim --cmd 'let g:minimal=1'"
        alias viu="vim -u NONE"
    fi
fi

################################################################################
#                          Fix my common typos                                 #
################################################################################

alias gti="git"
alias got="git"
alias gut="git"
alias gi="git"

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

alias sshkey='ssh-keygen -t rsa -b 4096 -C "${MAIL:-mickiller.25@gmail.com}"'

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
    # VCS
    export AUTO_NTFY_DONE_IGNORE="git hg svn"
    # Editors
    export AUTO_NTFY_DONE_IGNORE="nvim vi vim emacs $AUTO_NTFY_DONE_IGNORE"
    # Programs
    export AUTO_NTFY_DONE_IGNORE="less more man watch screen meld htop top ssh fg sudoedit make cmake cd fzf clear ctags fuck $AUTO_NTFY_DONE_IGNORE"
    # Typos
    export AUTO_NTFY_DONE_IGNORE="bim cim im bi ci nvi vnim gti got gut gi guck fukc gukc please fuvk $AUTO_NTFY_DONE_IGNORE"
    # alias
    export AUTO_NTFY_DONE_IGNORE="py py3 py2 cl nvi del usage vimv extract ports searchpkg fe fkill fssh $AUTO_NTFY_DONE_IGNORE"
    # GUI
    export AUTO_NTFY_DONE_IGNORE="nautilus gonvim firefox vlc $AUTO_NTFY_DONE_IGNORE"
    eval "$(ntfy shell-integration)"
fi

if hash cleanswap 2>/dev/null; then
    alias cw="cleanswap"
fi

# laod kernel module for virtualbox
if [[ $EUID -ne 0 ]]; then
    alias vbk="sudo modprobe vboxdrv"
else
    alias vbk="modprobe vboxdrv"
fi

if hash ctags 2>/dev/null; then
    # Get Fucking Tags
    alias gft="ctags -R ."
fi

################################################################################
#                               Systemctl                                      #
################################################################################

if hash systemctl 2>/dev/null; then
    if [[ $EUID -ne 0 ]]; then
        alias sysctl="sudo systemctl"
        alias usysctl="systemctl --user"

        alias ctls="sudo systemctl start"   # Start
        alias ctlr="sudo systemctl restart" # Restart
        alias ctlw="sudo systemctl status"  # shoW
        alias ctlh="sudo systemctl stop"    # Halt
    else
        alias sysctl="systemctl"
        alias usysctl="systemctl --user"

        alias ctls="systemctl start"   # Start
        alias ctlh="systemctl stop"    # Halt
        alias ctlr="systemctl restart" # Restart
        alias ctlw="systemctl status"  # shoW
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

if hash docker 2>/dev/null; then
    if [[ $EUID -ne 0 ]] && [[ ! "$(groups)" =~ .*docker.* ]]; then
        alias docker="sudo docker"
        alias docker-compose="sudo docker-compose"
    fi

    alias dkpa="docker ps -a"
fi

# Yeah I'm too lazy to remember each command in every distro soooooo
# I added this alias
# TODO add other distros commands I've used, like Solus
pkg=""
if hash yaourt 2>/dev/null || hash pacman 2>/dev/null; then
    # 'Install' package maybe in the PATH

    if hash yaourt 2>/dev/null; then
        pkg="yaourt"
    elif hash pacman 2>/dev/null; then
        # Yeah Arch from scratch may not have yaourt
        pkg="pacman"
    fi

    if ! hash fzf 2>/dev/null; then
        alias searchpkg="${pkg} -Ss"
    else
        function searchpkg() {
            if hash yaourt 2>/dev/null; then
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

    alias getpkg="${pkg} -S" && alias getpkgn="${pkg} -S --noconfirm"

    alias update="${pkg} -Syyu --aur" && alias updaten="${pkg} -Syyu --aur --noconfirm"

    alias rmpkg="${pkg} -Rns"

    if [[ $EUID -ne 0 ]] && ! hash yaourt 2>/dev/null; then
        unalias getpkg && alias getpkg="sudo ${pkg} -S"
        unalias getpkgn && alias getpkgn="sudo ${pkg} -S --noconfirm"

        unalias update && alias update="sudo ${pkg} -Syyu --aur"
        unalias updaten && alias updaten="sudo ${pkg} -Syyu --aur --noconfirm"

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
        alias getpkg="sudo ${pkg} install"
        alias getpkgn="sudo ${pkg} install -y"

        alias update="sudo ${pkg} update && sudo ${pkg} upgrade"
        alias updaten="sudo ${pkg} update && sudo ${pkg} upgrade -y"

        alias rmpkg="sudo ${pkg} remove"
    else
        alias getpkg="${pkg} install"
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
        alias getpkg="sudo ${pkg} install"
        alias getpkgn="sudo ${pkg} -y install"

        alias update="sudo ${pkg} update"
        alias updaten="sudo ${pkg} update -y"

        alias rmpkg="sudo ${pkg} remove"
    else
        alias getpkg="${pkg} install"
        alias getpkgn="${pkg} -y install"

        alias update="${pkg} update"
        alias updaten="${pkg} update -y"

        alias rmpkg="${pkg} remove"
    fi
fi

unset pkg

if hash fzf 2>/dev/null; then
    if hash git 2>/dev/null; then
        if hash fd 2>/dev/null; then
            export FZF_DEFAULT_COMMAND='(git --no-pager ls-files -co --exclude-standard || fd --type f --hidden --follow --color always -E "*.spl" -E "*.aux" -E "*.out" -E "*.o" -E "*.pyc" -E "*.gz" -E "*.pdf" -E "*.sw" -E "*.swp" -E "*.swap" -E "*.com" -E "*.exe" -E "*.so" -E "*/cache/*" -E "*/__pycache__/*" -E "*/tmp/*" -E ".git/*" -E ".svn/*" -E ".xml" -E "*.bin" -E "*.7z" -E "*.dmg" -E "*.gz" -E "*.iso" -E "*.jar" -E "*.rar" -E "*.tar" -E "*.zip" -E "TAGS" -E "tags" -E "GTAGS" -E "COMMIT_EDITMSG" . . ) 2> /dev/null'
            export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
            export FZF_ALT_C_COMMAND="fd --color always -t d . $HOME"
        elif hash rg 2>/dev/null; then
            export FZF_DEFAULT_COMMAND='(git --no-pager ls-files -co --exclude-standard || rg --line-number --column --with-filename --color always --no-search-zip --hidden --trim --files . ) 2> /dev/null'
            export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        elif hash ag 2>/dev/null; then
            export FZF_DEFAULT_COMMAND='(git --no-pager ls-files -co --exclude-standard || ag -l --follow --color --nogroup --hidden -g "" ) 2> /dev/null'
            export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        else
            export FZF_DEFAULT_COMMAND='(git --no-pager ls-files -co --exclude-standard || find . -iname "*") 2> /dev/null'
            export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        fi
    fi

    export FZF_CTRL_R_OPTS='--sort'

    export FZF_DEFAULT_OPTS='--layout=reverse --border --ansi'

    if ! is_windows; then
        export FZF_DEFAULT_OPTS="--height 40% $FZF_DEFAULT_OPTS"
    fi

    # Use ~~ as the trigger sequence instead of the default **
    export FZF_COMPLETION_TRIGGER='**'

    # Options to fzf command
    export FZF_COMPLETION_OPTS='+c -x'

    function cd() {
        if [[ "$#" != 0 ]]; then
            builtin cd "$@" || return
            return
        fi
        while true; do
            # collect dirs
            # shellcheck disable=SC2155
            if [[ -n "$(git rev-parse --git-dir 2>/dev/null)" ]]; then
                local folders=$(git ls-tree -rt HEAD "$(git rev-parse --show-toplevel)" | awk '{if ($2 == "tree") print $4;}')
            elif hash fd 2>/dev/null; then
                # shellcheck disable=SC2155
                local folders="$(fd -t d . .)"
            else
                # shellcheck disable=SC2155
                local folders="$(find . -type d -iname '*')"
            fi

            # shellcheck disable=SC2155
            local select=$(printf '%s\n' "${folders[@]}" | fzf)

            [[ ${#select} != 0 ]] || return 0
            builtin pushd "$select" &>/dev/null && return 0 || return 1
        done
    }

    # fkill - kill processes - list only the ones you can kill. Modified the earlier script.
    fkill() {
        local pid
        if [ "$UID" != "0" ]; then
            pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
        else
            pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
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
#                              Some miscellaneous                              #
################################################################################

if is_windows; then
    export CYGWIN=winsymlinks:native
fi

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
    if hash deactivate 2> /dev/null; then
        deactivate
    else
        killssh
        exit
    fi
}

function venv() {
    local _git=0
    local _name="env"
    local _top="."

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
            -g|--git)
                local _git=1
                ;;
            *)
                local _name="$2"
                shift
                ;;
        esac
        shift
    done

    if [[ $_git -eq 1 ]]; then
        if ! git rev-parse --show-toplevel 1> /dev/null; then
            echo "[X]     ---- Error!!!   Git repo error"
            return 1
        fi

        _top="$(git rev-parse --show-toplevel)"
        _top="$_top/.git"

        _name="$_top/$_name"
    fi

    if [[ ! -f "$_name/bin/activate" ]]; then
        echo "[X]     ---- Error!!!  Missing activate file, $_name/bin/activate" 1>&2
        return 1
    fi

    source "$_name/bin/activate"

    return 0
}

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
