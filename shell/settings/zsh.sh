#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   Author: Mike 8a                                                            #
#   Description: Extra zsh settings                                            #
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

# Remove terminal sounds
unsetopt beep

# Path to your oh-my-zsh installation.
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    export ZSH="$HOME/.oh-my-zsh"
fi

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# pip zsh completion start
if hash pip 2>/dev/null || hash pip2 2>/dev/null || hash pip3 2>/dev/null ; then
    function _pip_completion {
        local words cword
        read -Ac words
        read -cn cword
        reply=( $( COMP_WORDS="$words[*]" \
                    COMP_CWORD=$(( cword-1 )) \
                    PIP_AUTO_COMPLETE=1 $words[1] ) )
    }
    hash pip 2>/dev/null && compctl -K _pip_completion pip
    hash pip2 2>/dev/null && compctl -K _pip_completion pip2
    hash pip3 2>/dev/null && compctl -K _pip_completion pip3
fi
# pip zsh completion end

# Write to the history file immediately, not when the shell exits.
setopt INC_APPEND_HISTORY
# Share history between all sessions.
setopt SHARE_HISTORY
# Expire duplicate entries first when trimming history.
setopt HIST_EXPIRE_DUPS_FIRST
# Do not record an entry that was just recorded again.
setopt HIST_IGNORE_DUPS
# Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_ALL_DUPS
# Do not display a line previously found.
setopt HIST_FIND_NO_DUPS
# Do not record an entry starting with a space.
setopt HIST_IGNORE_SPACE
# Do not write duplicate entries in the history file.
setopt HIST_SAVE_NO_DUPS
# Remove superfluous blanks before recording entry.
setopt HIST_REDUCE_BLANKS
# Do not execute immediately upon history expansion.
setopt HIST_VERIFY

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    plugins=(go git python)
    # Set name of the theme to load. Optionally, if you set this to "random"
    # it'll load a random theme each time that oh-my-zsh is loaded.
    # See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
    [[ -z $ZSH_THEME ]] && ZSH_THEME="agnoster"

    # Uncomment the following line to use case-sensitive completion.
    CASE_SENSITIVE="true"

    # Uncomment the following line to use hyphen-insensitive completion. Case
    # sensitive completion must be off. _ and - will be interchangeable.
    # HYPHEN_INSENSITIVE="true"

    # Uncomment the following line to disable bi-weekly auto-update checks.
    # DISABLE_AUTO_UPDATE="true"

    # Uncomment the following line to change how often to auto-update (in days).
    # export UPDATE_ZSH_DAYS=13

    # Uncomment the following line to disable colors in ls.
    # DISABLE_LS_COLORS="true"

    # Uncomment the following line to disable auto-setting terminal title.
    # DISABLE_AUTO_TITLE="true"

    # Uncomment the following line to enable command auto-correction.
    [[ -z $ENABLE_CORRECTION ]] && ENABLE_CORRECTION="true"

    # Uncomment the following line to display red dots whilst waiting for completion.
    # COMPLETION_WAITING_DOTS="true"

    # Uncomment the following line if you want to disable marking untracked files
    # under VCS as dirty. This makes repository status check for large repositories
    # much, much faster.
    # DISABLE_UNTRACKED_FILES_DIRTY="true"

    # Uncomment the following line if you want to change the command execution time
    # stamp shown in the history command output.
    # The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
    # HIST_STAMPS="mm/dd/yyyy"

    # Set Xterm/screen/Tmux title with only a short hostname.
    # Uncomment this (or set SHORT_HOSTNAME to something else),
    # Will otherwise fall back on $HOSTNAME.
    [[ -z $SHORT_HOSTNAME ]] && export SHORT_HOSTNAME=$(hostname -s)


    source "$ZSH/oh-my-zsh.sh"
else
    # Case insesitive tab completion
    zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
    autoload -U colors && colors
    # autoload -U promptinit && promptinit
    # prompt -p redhat
    # prompt -s redhat

    PROMPT="%F%{$fg[red]%}%n%f%{$reset_color%}@%F%{$fg[cyan]%}%m%f %F%{$fg[yellow]%}%~%f %#%{$reset_color%}"$'\n'"→ "
fi

if hash fzf 2>/dev/null; then
    [[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
fi
