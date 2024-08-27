#!/usr/bin/env tcsh

# Magic tcsh stuff
set autolist
if ($?CLEARCASE_ROOT) then
    setenv CC_VIEW_NAME `echo "$CLEARCASE_ROOT" | awk -F/ -v pat="${USER}_at_" '{gsub(pat, "", $3 ) ; print $3}'`
    set prompt="\n%B`[ $USER = root ] && echo $USER@`%b%m: %B[%~]%b - CC: %B$CC_VIEW_NAME%b\n> "
else
    set prompt="\n%B`[ $USER = root ] && echo $USER@`%b%m: %B[%~]%b\n> "
endif

if ( -d "$HOME/.fzf/bin/" ) then
    setenv PATH "$HOME/.fzf/bin/:${PATH}"
endif
if ( `where tmux` != "" ) then
    bindkey -c ^a "tmux a || tmux new -s main"
endif
