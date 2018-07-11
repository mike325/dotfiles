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

if ( `where vim` != "" ) then
    if ( `where nvim` != "" ) then
        alias cdvi "cd ~/.vim"
        alias cdvim "cd ~/.conendifg/nvim"
        # NOTE: This is set inside Neovim settings
        # shellcheck disable=SC2154
        if ( ! ($?nvr) ) then
            setenv MANPAGER "nvim -R --cmd 'let g:minimal=0' -c 'setlocal readonly nomodifiable ft=man' -"
            setenv GIT_PAGER "nvim --cmd 'let g:minimal=0' -c 'setlocal ft=git readonly nomodiendifable' - "
            setenv EDITOR "nvim"
            alias vi "nvim --cmd 'let g:minimal=0'"
            alias viu "nvim -u NONE"
            # Fucking typos
            alias nvi "nvim"
            alias vnim "nvim"
        else
            setenv MANPAGER "nvr -cc 'setlocal modiendifable' -c 'silent! setlocal ft=man' --remote-tab -"
            setenv GIT_PAGER "nvr -cc 'setlocal modiendifable' -c 'setlocal ft=git readonly nomodifiable' --remote-tab -"
            setenv EDITOR "nvr --remote-tab"
            alias vi "nvr --remote-silent"
            alias nvi "nvr --remote-silent"
            alias nvim "nvr --remote-silent"
            alias vnim "nvr --remote-silent"
        endif
    else
        alias cdvim "cd ~/.vim"
        setenv MANPAGER "env MAN_PN=1 vim -R --cmd 'let g:minimal=0' -c 'silent! setlocal ft=man readonly nomodifiable' +MANPAGER -"
        setenv GIT_PAGER "vim --cmd 'let g:minimal=0' --cmd 'setlocal modiendifable' -c 'setlocal ft=git readonly nomodifiable' -"
        setenv EDITOR "vim"

        alias vi "vim --cmd 'let g:minimal=0'"
        alias viu "vim -u NONE"
    endif
endif


################################################################################
#                          endifx my common typos                                 #
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

# laod kernel module for virtualbox
# ( $EUID -ne 0 ) && alias vbk "sudo modprobe vboxdrv"

################################################################################
#             Functions to move around dirs and other simple stuff             #
#                                                                              #
#                      NO FUCKING FUNCTIONS IN TCSH                            #
################################################################################

alias bk "cd .."


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
