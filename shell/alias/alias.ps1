New-Alias -Name cl -Value 'cls' -ErrorAction SilentlyContinue
New-Alias -Name ll -Value 'ls' -ErrorAction SilentlyContinue
New-Alias -Name unset -Value 'Remove-Item' -ErrorAction SilentlyContinue

if (Get-Command "python" -ErrorAction SilentlyContinue) {
    New-Alias -Name py  -Value 'python'  -ErrorAction SilentlyContinue
}

if (Get-Command "python2" -ErrorAction SilentlyContinue) {
    New-Alias -Name py2 -Value 'python2' -ErrorAction SilentlyContinue
}

if (Get-Command "python3" -ErrorAction SilentlyContinue) {
    New-Alias -Name py3 -Value 'python3' -ErrorAction SilentlyContinue
}

# Typos
if (Get-Command "git" -ErrorAction SilentlyContinue) {
    New-Alias -Name gti -Value 'git' -ErrorAction SilentlyContinue
    New-Alias -Name got -Value 'git' -ErrorAction SilentlyContinue
    New-Alias -Name gut -Value 'git' -ErrorAction SilentlyContinue
    # New-Alias -Name gi  -Value 'git' -ErrorAction SilentlyContinue
}

if ( Get-Command "nvim.exe" -ErrorAction SilentlyContinue ) {
    function cdvim {
        cd "$HOME\AppData\Local\nvim"
    }

    function cdvi {
        cd "$HOME\vimfiles\"
    }

    if ($env:nvr -ne $null) {
        $nvr_path = (which nvr)
        New-Alias -Name nvr -Value $nvr_path -ErrorAction SilentlyContinue

        function vi {
            nvr --remote-silent $args
        }

        function vim {
            nvr --remote-silent $args
        }

        function nvim {
            nvr --remote-silent $args
        }

        # No man pages for windows
        # $env:MANPAGER  = "nvr.exe -cc 'setlocal modifiable' -c 'silent! setlocal nomodifiable ft=man' --remote-tab -"
        $env:GIT_PAGER = "nvr.exe -cc 'setlocal modifiable' -c 'setlocal ft=git nomodifiable' --remote -"
        $env:EDITOR    = "nvr.exe --remote-wait"

    }
    else {

        # No man pages for windows
        # $env:MANPAGER  = "nvim.exe --cmd 'let g:minimal=0' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal nomodifiable ft=man' -"
        $env:GIT_PAGER = "nvim.exe --cmd 'let g:minimal=0' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal ft=git nomodifiable' - "
        $env:EDITOR    = "nvim.exe"

        function vi {
            nvim.exe --cmd 'let g:minimal=0' $args
        }

        function viu {
            nvim.exe -u NONE $args
        }

        # Fucking typos
        New-Alias -Name nvi  -Value 'nvim.exe' -ErrorAction SilentlyContinue
        New-Alias -Name vnim -Value 'nvim.exe' -ErrorAction SilentlyContinue

    }

    New-Alias -Name bi -Value 'vi' -ErrorAction SilentlyContinue
    New-Alias -Name ci -Value 'vi' -ErrorAction SilentlyContinue
}
else {
    function cdvim {
        cd "$HOME\vimfiles"
    }

    function cdvi {
        cd "$HOME\vimfiles\"
    }
}
