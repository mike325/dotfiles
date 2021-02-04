#!/usr/bin/env bash

# Use <C-s> in terminal vim
[[ $- == *i* ]] && stty -ixon

################################################################################
#                         Make some dir that I normally use                    #
################################################################################
if [[ -z "$XDG_DATA_HOME" ]]; then
    export XDG_DATA_HOME="$HOME/.local/share"
    [[ ! -d "$XDG_DATA_HOME" ]] && mkdir -p "$XDG_DATA_HOME"
fi

if [[ -z "$XDG_CONFIG_HOME" ]]; then
    export XDG_CONFIG_HOME="$HOME/.config"
    [[ ! -d "$XDG_CONFIG_HOME" ]] && mkdir -p "$XDG_CONFIG_HOME"
fi

if [[ -z "$XDG_CACHE_HOME" ]]; then
    export XDG_CACHE_HOME="$HOME/.cache"
    [[ ! -d "$XDG_CACHE_HOME" ]] && mkdir -p "$XDG_CACHE_HOME"
fi

[[ ! -d "$HOME/.local/bin" ]] && mkdir -p "$HOME/.local/bin"
[[ ! -d "$HOME/.local/lib" ]] && mkdir -p "$HOME/.local/lib"
[[ ! -d "$HOME/.local/share" ]] && mkdir -p "$HOME/.local/share"
[[ ! -d "$HOME/.local/golang/src" ]] && mkdir -p "$HOME/.local/golang/src"
[[ ! -d "$HOME/.local/golang/pkgs" ]] && mkdir -p "$HOME/.local/golang/pkgs"
# [[ ! -d "$HOME/.local/git/template" ]] && mkdir -p "$HOME/.local/git/template"
# [[ ! -d "$HOME/.local/git/hooks" ]] && mkdir -p "$HOME/.local/git/hooks"
# [[ ! -d "$HOME/.local/git/bin" ]] && mkdir -p "$HOME/.local/git/bin"

# Load profile settings
# if [[ -f $HOME/.profile ]]; then
#     source $HOME/.profile
# fi

# Load all proxy settings
if [[ -f "$HOME/.config/shell/host/proxy.sh"  ]]; then
    # We already checked the file exists so its "safe"
    # shellcheck disable=SC1090,SC1091
    source "$HOME/.config/shell/host/proxy.sh"
    function toggleProxy() {
        # shellcheck disable=SC2154
        if [[ -n "$http_proxy" ]]; then
            unset "http_proxy"
            unset "https_proxy"
            unset "ftp_proxy"
            unset "socks_proxy"
            unset "no_proxy"
            echo "Proxy disable"
        else
            # shellcheck disable=SC1090,SC1091
            source "$HOME/.config/shell/host/proxy.sh"
            echo "Proxy enable"
        fi
    }
fi

# Load all ENV variables
# We already checked the file exists so its "safe"
# shellcheck disable=SC1090,SC1091
[[ -f "$HOME/.config/shell/host/env.sh"  ]] && source "$HOME/.config/shell/host/env.sh"
[[ -d "$HOME/.config/git/bin" ]] && export PATH="$HOME/.config/git/bin:$PATH"
[[ -d "$HOME/.local/bin/" ]] && export PATH="$HOME/.local/bin/:$PATH"
[[ -d "$HOME/.fzf/bin/" ]] && export PATH="$HOME/.fzf/bin/:$PATH"
[[ -d "$HOME/.luarocks/bin" ]] && export PATH="$HOME/.luarocks/bin/:$PATH"
[[ -d "/usr/sbin/" ]] && export PATH="/usr/sbin/:$PATH"

# If you have a custom pythonstartup script, you could set it in "env" file
if [[ -f "$HOME/.local/lib/pythonstartup.py" ]]; then
    export PYTHONSTARTUP="$HOME/.local/lib/pythonstartup.py"
elif [[ -f "$PYTHONSTARTUP_SCRIPT" ]]; then
    export PYTHONSTARTUP="$PYTHONSTARTUP_SCRIPT"
fi

# TODO: Add a path check function to avoid duplicates

# If Neovim is installed in a different path, you could set it in "env" file
if [[ -d "$HOME/.local/neovim/bin" ]]; then
    export PATH="$HOME/.local/neovim/bin:$PATH"
elif [[ -d "$NEOVIM_PATH" ]]; then
    export PATH="$NEOVIM_PATH:$PATH"
fi

# if hash gem 2> /dev/null; then
#     _GEM_USER_PATH=$(gem environment | grep -i 'user install' | awk '{print $5}')
#     if [[ -d "${_GEM_USER_PATH}/bin" ]]; then
#         export PATH="${_GEM_USER_PATH}/bin:$PATH"
#     fi
# fi

[[ -d "$HOME/.local/golang/bin" ]] && export PATH="$HOME/.local/golang/bin:$PATH"
[[ -d "$HOME/.local/golang/src" ]] && export GOPATH="$HOME/.local/golang/src"
[[ -d "$HOME/.gem/ruby/2.6.0/bin" ]] && export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"

if hash npm 2>/dev/null; then
    [[ ! -d "$HOME/.npm-global/" ]] && mkdir -p "$HOME/.npm-global"
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

################################################################################
#                       Load the settings, alias and framework                 #
################################################################################

if [ -z "$SHELL_PLATFORM" ]; then
    if [[ -n $TRAVIS_OS_NAME ]]; then
        export SHELL_PLATFORM="$TRAVIS_OS_NAME"
    else
        case "$OSTYPE" in
            *'linux'*   ) export SHELL_PLATFORM='linux' ;;
            *'darwin'*  ) export SHELL_PLATFORM='osx' ;;
            *'freebsd'* ) export SHELL_PLATFORM='bsd' ;;
            *'cygwin'*  ) export SHELL_PLATFORM='cygwin' ;;
            *'msys'*    ) export SHELL_PLATFORM='msys' ;;
            *'windows'* ) export SHELL_PLATFORM='windows' ;;
            *           ) export SHELL_PLATFORM='unknown' ;;
        esac
    fi
fi

function is_windows() {
    if [[ $SHELL_PLATFORM =~ (msys|cygwin|windows) ]]; then
        return 0
    fi
    return 1
}

function is_wsl() {
    if [[ "$(uname -r)" =~ Microsoft ]] ; then
        return 0
    fi
    return 1
}

function is_osx() {
    if [[ $SHELL_PLATFORM == 'osx' ]]; then
        return 0
    fi
    return 1
}

function is_linux() {
    if ! is_windows && ! is_wsl && ! is_osx; then
        return 0
    fi
    return 1
}

function is_root() {
    if ! is_windows && [[ $EUID -eq 0 ]]; then
        return 0
    fi
    return 1
}

function has_sudo() {
    if ! is_windows && hash sudo 2>/dev/null && [[ "$(groups)" =~ sudo ]]; then
        return 0
    fi
    return 1
}

# TODO: This should work with ARM 64bits
function is_64bits() {
    if [[ "$(uname -m)" =~ (x86_64) ]]; then
        return 0
    fi
    return 1
}

if [[ -n "$ZSH_NAME" ]]; then
    CURRENT_SHELL="zsh"
elif [[ -n "$BASH" ]]; then
    CURRENT_SHELL="bash"
else
    # shellcheck disable=SC2009,SC2046
    # CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
    # CURRENT_SHELL="${CURRENT_SHELL##*/}"
    # CURRENT_SHELL="${CURRENT_SHELL##*:}"
    if [[ -z "$CURRENT_SHELL" ]]; then
        CURRENT_SHELL="${SHELL##*/}"
    fi
fi

if is_windows; then
    export USER="$USERNAME"
fi

if is_windows; then
    # Windows user paths where pip install python packages
    if [[ -d "$HOME/AppData/Roaming/Python/Scripts" ]]; then
        export PATH="$HOME/AppData/Roaming/Python/Scripts:$PATH"
    fi

    windows_root="/c/Python"
    windows_user="$HOME/AppData/Roaming/Python/Python27/Scripts"

    if [[ -d "${windows_root}/Python27/Scripts" ]]; then
        export PATH="${windows_root}/Python27/Scripts:$PATH"
    fi

    # Override Root packeges
    if [[ -d "${windows_user}/Python/Python27/Scripts" ]]; then
        export PATH="${windows_user}/Python/Python27/Scripts:$PATH"
    fi

    python3=("39" "38" "37" "36" "35" "34")

    for version in "${python3[@]}"; do
        if [[ -d "${windows_root}/Python${version}/Scripts" ]]; then
            export PATH="${windows_root}/Python${version}/Scripts:$PATH"
        fi

        # Override Root packeges
        if [[ -d "${windows_user}/Python/Python${version}/Scripts" ]]; then
            export PATH="${windows_user}/Python/Python${version}/Scripts:$PATH"
        fi

        if [[ -d "${windows_root}/Python${version}/Scripts" ]] || [[ -d "${windows_user}/Python/Python${version}/Scripts" ]]; then
            break
        fi
    done

    export PYTHONIOENCODING="utf8"

fi

export _DEFAULT_SHELL="${SHELL##*/}"

if hash gtags 2>/dev/null; then
    export GTAGSLABEL=pygments
fi

if [[ $- == *i* ]]; then

    # Set terminal colors
    if [[  -n "$DISPLAY" ]] && [[ "$TERM" == "xterm" ]]; then
        export TERM=xterm-256color
    fi

    # Make less colorful
    export LESS=' -R '

    # Load custom shell framework settings (override default shell framework settings)
    if [[ -f  "$HOME/.config/shell/host/framework.sh" ]]; then
        # We already checked the file exists so its "safe"
        # shellcheck disable=SC1090,SC1091
        source "$HOME/.config/shell/host/framework.sh"
    fi

    # Configure shell framework and specific shell settings
    if [[ -f  "$HOME/.config/shell/settings/${CURRENT_SHELL}.sh" ]]; then
        # We already checked the file exists so its "safe"
        # shellcheck disable=SC1090,SC1091
        source "$HOME/.config/shell/settings/${CURRENT_SHELL}.sh"

        # I prefer the cool sl and the bins in my path
        _kill_alias=(ips usage del down4me)

        for i in "${_kill_alias[@]}"; do
            if [[ "$(command -V "$i")" =~ function ]]; then
                unset -f "$i"
            elif [[ $(command -V "$i") =~ alias ]]; then
                unalias "$i"
            fi
        done

    fi

    # Load alias after bash-it to give them higher priority
    if [[ -f "$HOME/.config/shell/alias/alias.sh"  ]]; then
        # We already checked the file exists so its "safe"
        # shellcheck disable=SC1090,SC1091
        source "$HOME/.config/shell/alias/alias.sh"
    fi

    # Load host settings (override general alias and funtions)
    if [[ -f  "$HOME/.config/shell/host/settings.sh" ]]; then
        # We already checked the file exists so its "safe"
        # shellcheck disable=SC1090,SC1091
        source "$HOME/.config/shell/host/settings.sh"
    fi

    if [[ -f "$HOME/.config/shell/scripts/z.sh" ]]; then
        # shellcheck disable=SC1090,SC1091
        source "$HOME/.config/shell/scripts/z.sh"
    fi

    # shellcheck disable=SC1090,SC1091
    [[ -n "$VIRTUAL_ENV" ]] && source "$VIRTUAL_ENV/bin/activate"
    [[ -f "$HOME/.config/shell/banner" ]] && cat "$HOME/.config/shell/banner"

fi
