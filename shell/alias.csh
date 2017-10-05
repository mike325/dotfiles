#!/usr/bin/env tcsh

################################################################################
#                                                                              #
#   Author: Mike 8a                                                            #
#   Description: Some useful alias                                             #
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

# if hash nvim 2>/dev/null then
#     export EDITOR='nvim'
#     VIM_PATH="$(command -v vim)"
#
#     # Prevent to screw the path alias
#     if [[ ! $VIM_PATH =~ "alias" ]] then
#         export MANPAGER="nvim -c 'set ft=man' -"
#         alias vim="nvim"
#         alias vi="$VIM_PATH"
#         alias cdvim="cd ~/.config/nvim"
#         alias cdvi="cd ~/.vim"
#     endif
# else
#     export EDITOR='vim'
#     export MANPAGER="env MAN_PN=1 vim -M +MANPAGER -"
#     alias cdvim="cd ~/.vim"
# endif

setenv EDITOR vim

setenv MANPAGER "env MAN_PN=1 vim -M +MANPAGER -"
alias cdvim "cd ~/.vim"

# Starts (n)vim with no settings at all
alias vimu "vim -u NONE"

# Starts (n)vim with minimal settings
# - Disable all plugins
# - Set my default settings, autocmds, and my key maps
alias vimm 'vim --cmd "let g:minimal=0"'

################################################################################
#                          Fix my common typos                                 #
################################################################################

alias gti "git"
alias got "git"
alias gut "git"
alias gi "git"

alias bim "vim"
alias cim "vim"
alias im "vim"

################################################################################
#                        Some useful shortcuts                                 #
################################################################################

alias q "exit"
alias cl "clear"

# if ( $EUID -ne 0 ) then
#     alias turnoff "sudo poweroff"
# else
#     alias turnoff "poweroff"
# endif

# Show used ports
alias ports "netstat -tulpn"

alias grep "grep --color -n"

alias grepo "grep -o"
alias grepe "grep -E"

alias ls 'ls --color'
alias la "ls -A"
alias ll "ls -lh"
alias lla "ls -lhA"

# This way sudo commands get the alias of the account
# ( $EUID -ne 0 ) && alias sudo 'sudo '

# Magnificent app which corrects your previous console command
# https://github.com/nvbn/thefuck
# if hash thefuck 2>/dev/null then
#     eval "$(thefuck --alias)"
#     alias fuck='eval $(thefuck $(fc -ln -1))'
#     alias please='fuck'
# endif

# laod kernel module for virtualbox
# ( $EUID -ne 0 ) && alias vbk "sudo modprobe vboxdrv"

# Generate tags file
# if hash ctags 2>/dev/null then
#     alias gtf="ctags -R ."
# endif

################################################################################
#                               Systemctl                                      #
################################################################################

# if hash systemctl 2>/dev/null then
#     if ( $EUID -ne 0 ) then
#         alias sysctl "sudo systemctl"
#         alias usysctl "systemctl --user"
#
#         alias ctls "sudo systemctl start"   # Start
#         alias ctlh "sudo systemctl stop"    # Halt
#         alias ctlr "sudo systemctl restart" # Restart
#         alias ctlw "sudo systemctl status"  # shoW
#     else
#         alias sysctl "systemctl"
#         alias usysctl "systemctl --user"
#
#         alias ctls "systemctl start"   # Start
#         alias ctlh "systemctl stop"    # Halt
#         alias ctlr "systemctl restart" # Restart
#         alias ctlw "systemctl status"  # shoW
#     endif
# endif

################################################################################
#                               Git shortcut                                   #
################################################################################


# if hash git 2>/dev/null then
#     alias clone="git clone"
#     alias ga="git add"
#     alias gs="git status"
#     alias gc="git commit"
#     alias gps="git push"
#     alias gpl="git pull"
#     alias gco="git checkout "
#     alias gr="git reset"
#     alias gss="git stash save"
#     alias gsp="git stash pop"
#     alias gsd="git stash drop"
#     alias gsa="git stash apply"
#     alias gsl="git stash list"
#     alias gsw="git stash show"
# endif

################################################################################
#                         Package management shortcuts                         #
################################################################################
# TODO Make a small function to install system basics

# if hash docker 2>/dev/null then
#     if [[ $EUID -ne 0 ]] then
#         alias docker="sudo docker"
#         alias docker-compose="sudo docker-compose"
#     endif
#
#     alias dkpa="docker ps -a"
# endif

# Yeah I'm too lazy to remember each command in every distro soooooo
# I added this alias
# TODO add other distros commands I've used, like Solus
# if hash yaourt 2>/dev/null then
#     # 'Install' package maybe in the PATH
#     alias get="yaourt -S"
#     alias getn="yaourt -S --noconfirm"
#
#     alias update="yaourt -Syyu --aur"
#
#     alias update="yaourt -Syyu --aur"
#     alias updaten="yaourt -Syyu --aur --noconfirm"
#
#     alias remove="yaourt -Rns"
#
#     # Yeah Arch from scratch may not have yaourt
# elif hash pacman 2>/dev/null then
#     if [[ $EUID -ne 0 ]] then
#         alias get="sudo pacman -S"
#         alias getn="sudo pacman -S --noconfirm"
#
#         alias update="sudo pacman -Syyu"
#         alias updaten="sudo pacman -Syyu --noconfirm"
#
#         alias remove="sudo pacman -Rns"
#     else
#         alias get="pacman -S"
#         alias getn="pacman -S --noconfirm"
#
#         alias update="pacman -Syyu"
#         alias updaten="pacman -Syyu --noconfirm"
#
#         alias remove="pacman -Rns"
#     endif
#
# elif hash apt-get 2>/dev/null then
#     if [[ $EUID -ne 0 ]] then
#         alias get="sudo apt-get install"
#         alias getn="sudo apt-get install -y"
#
#         alias update="sudo apt-get update && sudo apt-get upgrade"
#
#         alias remove="sudo apt-get remove"
#     else
#         alias get="apt-get install"
#         alias getn="apt-get install -y"
#
#         alias update="apt-get update && apt-get upgrade"
#
#         alias remove="apt-get remove"
#     endif
#
# elif hash dnf 2>/dev/null then
#     if [[ $EUID -ne 0 ]] then
#         alias get="sudo dnf install"
#         alias getn="sudo dnf -y install"
#
#         alias update="sudo dnf update"
#
#         alias remove="sudo dnf remove"
#     else
#         alias get="dnf install"
#         alias getn="dnf -y install"
#
#         alias update="dnf update"
#
#         alias remove="dnf remove"
#     endif
# endif


################################################################################
#             Functions to move around dirs and other simple stuff             #
#                                                                              #
#                      NO FUCKING FUNCTIONS IN TCSH                            #
################################################################################

alias bk "cd .."
# function bk() {
#     for key in "$@" do
#         case "$key" in
#             -h|--help)
#
#                 echo ""
#                 echo "  Function to go back any number of dirs"
#                 echo ""
#                 echo "  Usage:"
#                 echo "      $ bk [Number of nodes to move back] [OPTIONAL]"
#                 echo "          Ex."
#                 echo "          $ bk 2 # = cd ../../"
#                 echo ""
#                 echo "      Optional Flags"
#                 echo "          -h, --help"
#                 echo "              Display help and exit. If you are seeing this,"
#                 echo "              that means that you already know it (nice)"
#                 echo ""
#
#                 return 0
#
#         esac
#     done
#
#     if [[ ! -z "$1" ]] && [[ $1 =~ ^[0-9]+$ ]] then
#         local parent="./"
#         for (( i = 0 i < $1 i++ )) do
#             local parent="${parent}../"
#         done
#         cd "$parent" || return 1
#     elif [[ -z "$1" ]] then
#         cd ..
#     else
#         echo "  ---- [X] Error Unexpected arg $1, please provide a number"
#         return 1
#     endif
# }

# function mkcd() {
#     for key in "$@" do
#         case "$key" in
#             -h|--help)
#
#                 echo ""
#                 echo "  Create a dir an move to it"
#                 echo ""
#                 echo "  Usage:"
#                 echo "      mkcd NEW_DIR [OPTIONAL]"
#                 echo "          Ex."
#                 echo "          $ mkcd new_foo"
#                 echo ""
#                 echo "      Optional Flags"
#                 echo "          -h, --help"
#                 echo "              Display help and exit. If you are seeing this, that means that you already know it (nice)"
#                 echo ""
#
#                 return 0
#
#         esac
#     done
#
#     if [[ ! -z "$1" ]] then
#         mkdir -p "$1"
#         cd "$1" || return 1
#     endif
# }

# function llg() {
#     if [[ ! -z "$1" ]] then
#         ls -lhA | grep "$@"
#     endif
# }

alias rl "rm -rf ./*.log"
# function rl() {
#     rm "$@" ./*.log
# }

# Init original path with HOME dir
# ORIGINAL_PATH="$(pwd)"

# Move to the realpath version of the curren working dir
# function crp() {
#     # Save the current path
#     ORIGINAL_PATH="$(pwd)"
#     cd "$(grp)" || return 1
# }

# Go back to the last sym path or $HOME
# function gobk() {
#     cd "$ORIGINAL_PATH" || return 1
# }


# if hash emacs 2>/dev/null then
#     function cmacs() {
#         emacsclient -nw "$@"
#     }
#
#     function gmacs() {
#         emacsclient -c "$@" &
#     }
#
#     function dmacs() {
#         emacs --daemon &
#     }
#
#     function kmacs() {
#         emacsclient -e "(kill-emacs)"
#     }
# endif

