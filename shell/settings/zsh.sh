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

autoload -Uz history-search-end
autoload -Uz compinit

# Set vi key mode
bindkey -v
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

[[ ! -d "$HOME/.zsh/" ]] && mkdir -p "$HOME/.zsh/"

# Path to your oh-my-zsh installation.
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ZSH="$HOME/.oh-my-zsh"
fi

if [[ -z $SHEL ]]; then
    SHELL='/bin/zsh'
fi

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then

    plugins=(
        golang
        git
        python
        history-substring-search
    )

    # Set name of the theme to load. Optionally, if you set this to "random"
    # it'll load a random theme each time that oh-my-zsh is loaded.
    # See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
    # [[ -z $ZSH_THEME ]] && ZSH_THEME="amuse"
    [[ -z $ZSH_THEME ]] && ZSH_THEME="bira"

    # CASE_SENSITIVE="true"

    # Uncomment the following line to disable auto-setting terminal title.
    # DISABLE_AUTO_TITLE="true"

    # Uncomment the following line to display red dots whilst waiting for completion.
    # COMPLETION_WAITING_DOTS="true"

    # Uncomment the following line if you want to disable marking untracked files
    # under VCS as dirty. This makes repository status check for large repositories
    # much, much faster.
    # DISABLE_UNTRACKED_FILES_DIRTY="true"

    # Set Xterm/screen/Tmux title with only a short hostname.
    # Uncomment this (or set SHORT_HOSTNAME to something else),
    # Will otherwise fall back on $HOSTNAME.
    [[ -z $SHORT_HOSTNAME ]] && export SHORT_HOSTNAME=$(hostname -s)

    if source "$ZSH/oh-my-zsh.sh"; then
        # bind UP and DOWN arrow keys (compatibility fallback
        # for Ubuntu 12.04, Fedora 21, and MacOSX 10.9 users)
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
        bindkey '^p' history-substring-search-up
        bindkey '^n' history-substring-search-down

        # bind k and j for VI mode
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
    fi

else
    # Case insesitive tab completion
    zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
    autoload -Uz colors
    # autoload -U promptinit && promptinit
    # prompt -p redhat
    # prompt -s redhat

    PROMPT="%F%{$fg[red]%}%n%f%{$reset_color%}@%F%{$fg[cyan]%}%m%f %F%{$fg[yellow]%}%~%f %#%{$reset_color%}"$'\n'"→ "
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

KEYTIMEOUT=20

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

bindkey -s '^a' 'tmux attach 2>/dev/null || tmux new -s main\n'
bindkey 'jj' vi-cmd-mode
bindkey -M viins 'jj' vi-cmd-mode

if hash fzf 2>/dev/null; then
    [[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
fi
