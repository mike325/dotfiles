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

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

[[ ! -d "$HOME/.zsh/" ]] && mkdir -p "$HOME/.zsh/"

# Path to your oh-my-zsh installation.
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    export ZSH="$HOME/.oh-my-zsh"
fi

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    plugins=(go git python)
    # Set name of the theme to load. Optionally, if you set this to "random"
    # it'll load a random theme each time that oh-my-zsh is loaded.
    # See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
    [[ -z $ZSH_THEME ]] && ZSH_THEME="agnoster"

    # CASE_SENSITIVE="true"

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

HISTFILE="$HOME/.zsh/history"
HISTSIZE=2048
SAVEHIST=2048

setopt inc_append_history     # Write to the history file immediately, not when the shell exits.
setopt share_history          # Share history between all sessions.
setopt hist_expire_dups_first # Expire duplicate entries first when trimming history.
setopt hist_ignore_dups       # Do not record an entry that was just recorded again.
setopt hist_ignore_all_dups   # Delete old recorded entry if new entry is a duplicate.
setopt hist_find_no_dups      # Do not display a line previously found.
setopt hist_ignore_space      # Do not record an entry starting with a space.
setopt hist_save_no_dups      # Do not write duplicate entries in the history file.
setopt hist_reduce_blanks     # Remove superfluous blanks before recording entry.
setopt hist_verify            # Do not execute immediately upon history expansion.
setopt hist_reduce_blanks

# Don't ask for rm * confirmation
setopt rmstarsilent

# Set vi key mode
bindkey -v
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

KEYTIMEOUT=1
