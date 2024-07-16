#!/usr/bin/env zsh

autoload -Uz history-search-end colors zcalc
colors

# export ARCHFLAGS="-arch x86_64"
# export SSH_KEY_PATH="~/.ssh/rsa_id"

[[ ! -d "$HOME/.zsh/" ]] && mkdir -p "$HOME/.zsh/"

# Path to your oh-my-zsh installation.
[[ -d "$HOME/.oh-my-zsh" ]] && ZSH="$HOME/.oh-my-zsh"
[[ -z $SHELL ]] && SHELL="$(which zsh)"

KEYTIMEOUT=20

# HISTFILE=~/.zhistory
HISTFILE=~/.zsh/history
HISTSIZE=10000
SAVEHIST=10000

setopt rmstarsilent           # Don't ask for rm * confirmation
setopt combiningchars         # Enabled utf-8
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

[[ ! -d "$HOME/.zsh/zfunctions" ]] && mkdir -p "$HOME/.zsh/zfunctions"

fpath+="$HOME/.config/shell/zfunctions"
fpath+="$HOME/.zsh/zfunctions"

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

export VIRTUAL_ENV_DISABLE_PROMPT=1

if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then

    plugins=(
        golang
        git
        python
        history-substring-search
    )

    [[ -z $ZSH_THEME ]] && ZSH_THEME="bira"
    [[ -z $SHORT_HOSTNAME ]] && export SHORT_HOSTNAME=$(hostname -s)

    source "$HOME/.oh-my-zsh/oh-my-zsh.sh"
else
    setopt prompt_subst
    # autoload _cwd
    autoload _cc_view
    autoload _username
    autoload _exit_code
    autoload _git_info
    autoload _venv
    autoload _proxy
    autoload toggleProxy

    autoload status_msg warn_msg error_msg

    _prompt_command() {
        local EXIT_CODE="$?"
        local prompt=""

        prompt="\n"
        # prompt+="$(__schroot_name)"
        prompt+="$(_username)"
        prompt+="%F{cyan}%m%f: "
        prompt+="%F{yellow}%~%f"
        # prompt+="$(_cwd)"
        prompt+="%F{magenta}%(1j. J:%j.)%f "
        prompt+="$(_proxy)"
        prompt+="$(_venv)"
        prompt+="$(_cc_view) "
        prompt+="$(_git_info) "
        prompt+="\n$(_exit_code $EXIT_CODE)"
        # prompt+="\n$ "

        echo "$prompt"
    }
    PROMPT='$(_prompt_command)'
fi

if [[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
    bindkey '^ ' autosuggest-execute
fi

if hash gh 2>/dev/null && [[ ! -f "$HOME/.zsh/zfunctions/_gh" ]]; then
    gh completion --shell zsh >"$HOME/.zsh/zfunctions/_gh"
fi

if hash ruff 2>/dev/null && [[ ! -f "$HOME/.zsh/zfunctions/_ruff" ]]; then
    ruff generate-shell-completion zsh >"$HOME/.zsh/zfunctions/_ruff"
fi

autoload -Uz compinit
compinit # -d

autoload -Uz bashcompinit
bashcompinit

# Case insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
# Partial completion suggestions
zstyle ':completion:*' list-suffixes zstyle ':completion:*' expand prefix suffix 
# Automatically find new executables in path
zstyle ':completion:*' rehash true

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

if hash kitty 2>/dev/null; then
    # Completion for kitty
    kitty + complete setup zsh | source /dev/stdin
fi

if [[ -d "$HOME/.local/share/completions/" ]]; then
    for cfile in "$HOME/.local/share/completions/"*; do
        if [[ $cfile =~ .*\.zsh$ ]]; then
            source "$cfile" 2>/dev/null
        fi
    done
fi

if hash fzf 2>/dev/null; then
    [[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
fi

# Set vi key mode
bindkey -v
# bindkey '^?' backward-delete-char
# bindkey '^h' backward-delete-char
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^r' history-incremental-search-backward

bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ ${terminfo[khome]} != ""   ]]; then
    bindkey "${terminfo[khome]}" beginning-of-line              # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                      # End key
if [[ ${terminfo[kend]} != ""   ]]; then
    bindkey "${terminfo[kend]}" end-of-line                     # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word
bindkey '^[Od' backward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[Z' undo # Shift+tab undo last action

# bind k and j for VI mode
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-substring-search-down
bindkey -M vicmd 'L' clear-screen

bindkey -s '^a' 'tmux attach -t main 2>/dev/null || tmux new -s main\n'
bindkey 'jj' vi-cmd-mode
bindkey -M viins 'jj' vi-cmd-mode

if hash fzf 2>/dev/null; then
    [[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
    bindkey -v
fi
