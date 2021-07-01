#!/usr/bin/env zsh

# Remove terminal sounds
unsetopt beep

autoload -Uz history-search-end
autoload -Uz compinit
compinit

# Set vi key mode
bindkey -v
# bindkey '^?' backward-delete-char
# bindkey '^h' backward-delete-char
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^r' history-incremental-search-backward

bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                      # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^[[Z' undo                                             # Shift+tab undo last action

# bind k and j for VI mode
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-substring-search-down

bindkey -s '^a' 'tmux attach 2>/dev/null || tmux new -s main\n'
bindkey 'jj' vi-cmd-mode
bindkey -M viins 'jj' vi-cmd-mode

# export ARCHFLAGS="-arch x86_64"
# export SSH_KEY_PATH="~/.ssh/rsa_id"

[[ ! -d "$HOME/.zsh/" ]] && mkdir -p "$HOME/.zsh/"

# Path to your oh-my-zsh installation.
[[ -d "$HOME/.oh-my-zsh" ]] && ZSH="$HOME/.oh-my-zsh"
[[ -z $SHELL ]] && SHELL='/bin/zsh'

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

# HISTFILE=~/.zhistory
HISTFILE=~/.zsh/history
HISTSIZE=10000
SAVEHIST=10000

setopt correct                # Auto correct mistakes
setopt extendedglob           # Extended globbing. Allows using regular expressions with *
setopt nocaseglob             # Case insensitive globbing
setopt rcexpandparam          # Array expension with parameters
setopt nocheckjobs            # Don't warn about running processes when exiting
setopt numericglobsort        # Sort filenames numerically when it makes sense
setopt nobeep                 # No beep
setopt appendhistory          # Immediately append history instead of overwriting
setopt histignorealldups      # If a new command is a duplicate, remove the older one
setopt autocd                 # if only directory path is entered, cd there.
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

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

if hash fzf 2>/dev/null; then
    [[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
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
else
    USE_POWERLINE="true"

    # Case insesitive tab completion
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
    zstyle ':completion:*' rehash true                              # automatically find new executables in path

    # Speed up completions
    zstyle ':completion:*' accept-exact '*(N)'
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path ~/.zsh/cache

    autoload -U compinit colors zcalc
    compinit -d
    colors

    # autoload -U promptinit && promptinit
    # prompt -p redhat
    # prompt -s redhat

    # Use manjaro zsh prompt
    if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
        source /usr/share/zsh/manjaro-zsh-prompt
    else
        PROMPT="%F%{$fg[red]%}%n%f%{$reset_color%}@%F%{$fg[cyan]%}%m%f %F%{$fg[yellow]%}%~%f %#%{$reset_color%}"$'\n'"→ "
    fi

fi

if hash kitty 2>/dev/null; then
    # Completion for kitty
    kitty + complete setup zsh | source /dev/stdin
fi
