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

# Set erase character
stty erase '^?'

################################################################################
#                         Make some dir that I normally use                    #
################################################################################
if ( ! -d "$HOME/.local/bin" ) mkdir -p "$HOME/.local/bin"
if ( ! -d "$HOME/.local/lib" ) mkdir -p "$HOME/.local/lib"
if ( ! -d "$HOME/.local/share" ) mkdir -p "$HOME/.local/share"
if ( ! -d "$HOME/.local/golang/src" ) mkdir -p "$HOME/.local/golang/src"

# Load all proxy settings
if ( -f "$HOME/.config/shell/host/proxy.csh" ) then
    source "$HOME/.config/shell/host/proxy.csh"
endif

# Load all ENV variables
if ( -f "$HOME/.config/shell/host/env.csh" ) then
    source "$HOME/.config/shell/host/env.csh"
endif

# If you have a custom pythonstartup script, you could set it in env.csh file
if ( -f "$HOME/.local/lib/pythonstartup.py" ) then
    setenv PYTHONSTARTUP "$HOME/.local/lib/pythonstartup.py"
endif

### Setting the PATH var
if ( -d "$HOME/.config/git/bin" ) then
    setenv PATH "$HOME/.config/git/bin:$PATH"
endif

if ( -d "$HOME/.local/bin/" ) then
    setenv PATH "$HOME/.local/bin/:$PATH"
endif

if ( -d "$HOME/.local/neovim/bin" ) then
    setenv PATH "$HOME/.local/neovim/bin:$PATH"
endif

if ( -d "$HOME/.fzf/bin/" ) then
    setenv PATH "$HOME/.fzf/bin/:$PATH"
endif

if ( -d "$HOME/.luarocks/bin" ) then
    setenv PATH "$HOME/.luarocks/bin:$PATH"
endif

if ( -d "$HOME/.local/golang/bin" ) then
    setenv PATH "$HOME/.local/golang/bin:$PATH"
endif

if ( -d "$HOME/.local/golang/src" ) then
    setenv GOPATH "$HOME/.local/golang/src"
endif

if ( -d "$HOME/.gem/ruby/2.6.0/bin" ) then
    setenv PATH "$HOME/.gem/ruby/2.6.0/bin:$PATH"
endif

################################################################################
#                       Load the settings, alias and framework                 #
################################################################################

if ($?prompt) then
    setenv CURRENT_SHELL `echo $shell | sed 's/.*\///g'`

    # Make less colorful
    setenv LESS ' -R '

    # Load custom shell framework settings (override default shell framework settings)
    # if ( -f  "$HOME/.config/shell/host/framework_settings" ) then
    #     source "$HOME/.config/shell/host/framework_settings"
    # endif

    # NOTE: can't make this crap works yet
    #
    # Configure shell framework and specific shell settings (Just bash and zsh)
    # are supported
    if ( -f  "$HOME/.config/shell/settings/${CURRENT_SHELL}.csh" ) then
        source "$HOME/.config/shell/settings/${CURRENT_SHELL}.csh"

        # # I prefer the cool sl and the bins in my path
        # set _kill_alias = ( ips usage myip del down4me sl )

        # foreach i ($_kill_alias)
        #     if ( `command -V $i` =~ function ) then
        #         unset -f $i
        #     else if ( `command -V $i` =~ alias ) then
        #         unalias $i
        #     endif
        # end
    endif

    # Load alias after bash-it to give them higher priority
    if ( -f "$HOME/.config/shell/alias/alias.csh"  ) then
        source "$HOME/.config/shell/alias/alias.csh"
    endif

    # # Load host settings (override general alias and funtions)
    if ( -f  "$HOME/.config/shell/host/settings.csh" ) then
        source "$HOME/.config/shell/host/settings.csh"
    endif

    if ( -f "$HOME/.config/shell/banner" ) then
        cat "$HOME/.config/shell/banner"
    endif
endif
