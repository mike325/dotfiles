#!/usr/bin/env tcsh

# Author: Mike 8a
# Description: Some useful alias and functions
# github.com/mike325/dotfiles

################################################################################
#                          Set the default text editor                         #
################################################################################

if ( `where nvim` != "" ) then
    setenv EDITOR "nvim"
    # Fucking typos
    alias nvi "nvim"
    alias vnim "nvim"
    alias vi "nvim --cmd 'let g:minimal=1'"

    setenv NVIM_LISTEN_ADDRESS "$HOME/.cache/nvim/socket$TMUX_WINDOW"

    alias cdvi "cd ~/.vim"
    alias cdvim "cd ~/.config/nvim"

    alias bim "nvim"
    alias cim "nvim"
    alias im "nvim"
else
    setenv EDITOR "vim"

    alias cdvim "cd ~/.vim"
    alias cdvi "cd ~/.vim"
    # setenv MANPAGER "env MAN_PN=1 vim --cmd 'let g:minimal=1 --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=man  nomodifiable' +MANPAGER -"
    alias vi "vim --cmd 'let g:minimal=1'"
    alias viu "vim -u NONE"

    alias bim "vim"
    alias cim "vim"
    alias im "vim"
endif

if ( `where delta` != "" ) then
    setenv GIT_PAGER "delta --dark --24-bit-color auto"
else
    if ( `where bat` != "" ) then
        setenv GIT_PAGER "bat"
        alias cat bat
    endif
endif

if ( `where bat` != "" ) then
    alias cat bat
    setenv MANPAGER "sh -c 'col -bx | bat -l man -p'"
endif

################################################################################
#                          Fix my common typos                                 #
################################################################################

alias bi "vi"
alias ci "vi"

alias gti "git"
alias got "git"
alias gut "git"
alias gi "git"

alias py "python"
alias py2 "python2"
alias py3 "python3"


################################################################################
#                        Some useful shortcuts                                 #
################################################################################

if ( `where thefuck` != "" ) then
    alias fuck 'set fucked_cmd=`history -h 2 | head -n 1` && eval `thefuck ${fucked_cmd}`'

    # Yep tons of fucks
    alias guck 'fuck'
    alias fukc 'fuck'
    alias gukc 'fuck'
    alias fuvk 'fuck'
endif

alias sshkey 'ssh-keygen -t rsa -b 4096 -C "${EMAIL:-mickiller.25@gmail.com}"'

alias user "whoami"
alias j "jobs"

# Check all user process
alias psu 'ps -u $USER'

alias cl "clear"
alias q "exit"

# Show used ports
alias ports "netstat -tulpn"

alias grep "grep --color -n"
alias grepo "grep -o"
alias grepe "grep -E"

alias ls "ls --color --classify --human-readable"
alias l "ls"
alias la "ls -A"
alias ll "ls -l"
alias lla "ls -lA"

alias lat "ls -A --sort=time --reverse"
alias llt "ls -l --sort=time --reverse"
alias llat "ls -lA --sort=time --reverse"

alias las "ls -A --sort=size --reverse"
alias lls "ls -l --sort=size --reverse"
alias llas "ls -lA --sort=size --reverse"

# default fd package in debian is fd-find, so we add a small alias to us fd
if ( `where fdfind` != "" ) then
    alias fd "fdfind"
endif

################################################################################
#             Functions to move around dirs and other simple stuff             #
#                                                                              #
#                      NO FUCKING FUNCTIONS IN TCSH                            #
################################################################################

alias bk "cd .."

alias rl "rm -rf ./.log"

if ( `where fzf` != "" ) then
    if ( `where git` != "" ) then
        if ( `where fd` != "" ) then
            setenv FZF_DEFAULT_COMMAND 'git --no-pager ls-files -co --exclude-standard || fd --type f --hidden --follow --color always -E "*.spl" -E "*.aux" -E "*.out" -E "*.o" -E "*.pyc" -E "*.gz" -E "*.pdf" -E "*.sw" -E "*.swp" -E "*.swap" -E "*.com" -E "*.exe" -E "*.so" -E "*/cache/*" -E "*/__pycache__/*" -E "*/tmp/*" -E ".git/*" -E ".svn/*" -E ".xml" -E "*.bin" -E "*.7z" -E "*.dmg" -E "*.gz" -E "*.iso" -E "*.jar" -E "*.rar" -E "*.tar" -E "*.zip" -E "TAGS" -E "tags" -E "GTAGS" -E "COMMIT_EDITMSG" . .  '
            setenv FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
            setenv FZF_ALT_C_COMMAND "fd --color always -t d . $HOME"
        else if ( `where rg` != "" ) then
            setenv FZF_DEFAULT_COMMAND 'git --no-pager ls-files -co --exclude-standard || rg --line-number --column --with-filename --color always --no-search-zip --hidden --trim --files . '
            setenv FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        else if ( `where ag` != "" ) then
            setenv FZF_DEFAULT_COMMAND 'git --no-pager ls-files -co --exclude-standard || ag -l --follow --color --nogroup --hidden --ignore "*.spl" --ignore "*.aux" --ignore "*.out" --ignore "*.o" --ignore "*.pyc" --ignore "*.gz" --ignore "*.pdf" --ignore "*.sw" --ignore "*.swp" --ignore "*.swap" --ignore "*.com" --ignore "*.exe" --ignore "*.so" --ignore "/cache/" --ignore "/__pycache__/" --ignore "/tmp/" --ignore ".git/" --ignore ".svn/" --ignore ".xml" --ignore "*.log" --ignore "*.bin" --ignore "*.7z" --ignore "*.dmg" --ignore "*.gz" --ignore "*.iso" --ignore "*.jar" --ignore "*.rar" --ignore "*.tar" --ignore "*.zip" --ignore "TAGS" --ignore "tags" --ignore "GTAGS" --ignore "COMMIT_EDITMSG" -g "" '
            setenv FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        else
            setenv FZF_DEFAULT_COMMAND "git --no-pager ls-files -co --exclude-standard || find . -iname '*'"
            setenv FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        endif
    endif
    setenv FZF_CTRL_R_OPTS '--sort'

    setenv FZF_DEFAULT_OPTS '--height 70% --layout=reverse --border --ansi'
    # Use ~~ as the trigger sequence instead of the default **
    setenv FZF_COMPLETION_TRIGGER '**'

    # Options to fzf command
    setenv FZF_COMPLETION_OPTS '+c -x'
endif

if ( `where tmux` != "" ) then
    alias tma "tmux a"
    alias tms "tmux new -s main"
    alias tmn "tmux new "
endif
