#!/usr/bin/env tcsh

################################################################################
#                                                                              #
#  NOT TESTED!!!! Draft of a simple/basic port of my shellrc                   #
#                                                                              #
#   Author: Mike 8a                                                            #
#   Description: Small shell configs                                           #
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

# Magic tcsh stuff
set addsuffix
set autolist
alias cmdcwd 'set prompt=$user@`hostname` at [$cwd]  '
# set correct=cmd

# Set erase character
stty erase '^?'

################################################################################
#                         Make some dir that I normally use                    #
################################################################################
if ( ! -d $HOME/.local/bin ) mkdir -p $HOME/.local/bin
if ( ! -d $HOME/.local/lib ) mkdir -p $HOME/.local/lib
if ( ! -d $HOME/.local/share ) mkdir -p $HOME/.local/share
if ( ! -d $HOME/.local/golang/src ) mkdir -p $HOME/.local/golang/src

# Load all proxy settings
if ( -f $HOME/.config/shell/host/proxy.csh ) then
    source $HOME/.config/shell/host/proxy.csh
endif

# Load all ENV variables
if ( -f $HOME/.config/shell/host/env.csh ) then
    source $HOME/.config/shell/host/env.csh
endif

# If you have a custom pythonstartup script, you could set it in env.csh file
if ( -f $HOME/.local/lib/pythonstartup.py ) then
    setenv PYTHONSTARTUP $HOME/.local/lib/pythonstartup.py
endif

### Setting the PATH var
if ( -d $HOME/.local/git/bin ) then
    setenv PATH $HOME/.local/git/bin:$PATH
endif

if ( -d $HOME/.local/bin/ ) then
    setenv PATH $HOME/.local/bin/:$PATH
endif

# If Neovim is installed in a different path, you could set it in env file
if ( -d $HOME/.local/neovim/bin ) then
    setenv PATH $HOME/.local/neovim/bin:$PATH
endif

if ( -d $HOME/.local/golang/bin ) then
    setenv PATH $HOME/.local/golang/bin:$PATH
endif

if ( -d $HOME/.local/golang/src ) then
    setenv GOPATH $HOME/.local/golang/src
endif

################################################################################
#                       Load the settings, alias and framework                 #
################################################################################

if ($?prompt) then
    # setenv _DEFAULT_SHELL ${SHELL##*/}

    # Make less colorful
    setenv LESS ' -R '

#     # Load custom shell framework settings (override default shell framework settings)
#     if ( -f  $HOME/.config/shell/host/framework_settings ) then
#         source $HOME/.config/shell/host/framework_settings
#     endif
#
#     # NOTE: can't make this crap works yet
#     #
#     # Configure shell framework and specific shell settings (Just bash and zsh)
#     # are supported
#     # if ( -f  $HOME/.config/shell/${_CURRENT_SHELL}_settings ) then
#     #     source $HOME/.config/shell/${_CURRENT_SHELL}_settings
#     #
#     #     # I prefer the cool sl and the bins in my path
#     #     set _kill_alias = ( ips usage myip del down4me sl )
#     #
#     #     foreach i ($_kill_alias)
#     #         if ( `command -V $i` =~ function ) then
#     #             unset -f $i
#     #         else if ( `command -V $i` =~ alias ) then
#     #             unalias $i
#     #         endif
#     #     end
#     # endif
#
    # Load alias after bash-it to give them higher priority
    if ( -f $HOME/.config/shell/alias.csh  ) then
        source $HOME/.config/shell/alias.csh
    endif

    # Load host settings (override general alias and funtions)
    if ( -f  $HOME/.config/shell/host/settings.csh ) then
        source $HOME/.config/shell/host/settings.csh
    endif

    echo    ""
    echo    "                               -'"
    echo    "               ...            .o+'"
    echo    "            .+++s+   .h'.    'ooo/"
    echo    "           '+++%++  .h+++   '+oooo:"
    echo    "           +++o+++ .hhs++. '+oooooo:"
    echo    "           +s%%so%.hohhoo'  'oooooo+:"
    echo    "           '+ooohs+h+sh++'/:  ++oooo+:"
    echo    "            hh+o+hoso+h+'/++++.+++++++:"
    echo    "             '+h+++h.+ '/++++++++++++++:"
    echo    "                      '/+++ooooooooooooo/'"
    echo    "                     ./ooosssso++osssssso+'"
    echo    "                    .oossssso-''''/osssss::'"
    echo    "                   -osssssso.      :ssss''to."
    echo    "                  :osssssss/  Mike  osssl   +"
    echo    "                 /ossssssss/   8a   +sssslb"
    echo    "               '/ossssso+/:-        -:/+ossss'.-"
    echo    "              '+sso+:-'                 '.-/+oso:"
    echo    "             '++:.                           '-/+/"
    echo    "             .'   github.com/mike325/dotfiles   '/"
    echo    ""
endif

