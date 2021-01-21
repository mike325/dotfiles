# Author: Mike 8a
# Description: Some useful alias and functions
# github.com/mike325/dotfiles

New-Alias -Name cl -Value 'cls' -ErrorAction SilentlyContinue;
New-Alias -Name ll -Value 'ls' -ErrorAction SilentlyContinue;
New-Alias -Name unset -Value 'Remove-Item' -ErrorAction SilentlyContinue;
Set-Alias trash Remove-ItemSafely;
set-alias unzip expand-archive;

function get-path {
    ($Env:Path).Split(";");
}

function open($file) {
    invoke-item $file;
}

# Truncate homedir to ~
function limit-HomeDirectory($Path) {
    $Path.Replace("$home", "~");
}

function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
    get-process $name -ErrorAction SilentlyContinue | stop-process;
}

function pgrep($name) {
    get-process $name;
}

if ( -Not (Get-Command "sudo" -ErrorAction SilentlyContinue) ) {
    function sudo() {
        Invoke-Elevated @args;
    }
}

$env:PYTHONIOENCODING="utf-8";

if (Get-Command "python" -ErrorAction SilentlyContinue) {
    New-Alias -Name py  -Value 'python'  -ErrorAction SilentlyContinue;
}

if (Get-Command "python2" -ErrorAction SilentlyContinue) {
    New-Alias -Name py2 -Value 'python2' -ErrorAction SilentlyContinue;
}

if (Get-Command "python3" -ErrorAction SilentlyContinue) {
    New-Alias -Name py3 -Value 'python3' -ErrorAction SilentlyContinue;
}

# Typos
if (Get-Command "git" -ErrorAction SilentlyContinue) {
    New-Alias -Name gti -Value 'git' -ErrorAction SilentlyContinue;
    New-Alias -Name got -Value 'git' -ErrorAction SilentlyContinue;
    New-Alias -Name gut -Value 'git' -ErrorAction SilentlyContinue;
    # New-Alias -Name gi  -Value 'git' -ErrorAction SilentlyContinue;
}

if ( Get-Command "nvim.exe" -ErrorAction SilentlyContinue ) {
    function cdvim {
        cd "$HOME\AppData\Local\nvim";
    }

    function cdvi {
        cd "$HOME\vimfiles\";
    }

    if ($env:nvr -ne $null) {
        $nvr_path = (which nvr);
        New-Alias -Name nvr -Value $nvr_path -ErrorAction SilentlyContinue;

        function vi {
            nvr --remote-silent $args;
        }

        function vim {
            nvr --remote-silent $args;
        }

        function nvim {
            nvr --remote-silent $args;
        }

        # No man pages for windows
        # $env:MANPAGER  = "nvr.exe -cc 'setlocal modifiable' -c 'silent! setlocal nomodifiable ft=man' --remote-tab -"
        $env:GIT_PAGER = "nvr.exe -cc 'setlocal modifiable' -c 'setlocal ft=git nomodifiable' --remote -";
        $env:EDITOR    = "nvr.exe --remote-wait";

    }
    else {

        # No man pages for windows
        # $env:MANPAGER  = "nvim.exe --cmd 'let g:minimal=1' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal nomodifiable ft=man' -"
        # $env:GIT_PAGER = "nvim.exe --cmd 'let g:minimal=1' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal ft=git nomodifiable' - "
        $env:EDITOR    = "nvim.exe";

        function vi {
            nvim.exe --cmd 'let g:minimal=1' $args;
        }

        function viu {
            nvim.exe -u NONE $args;
        }

        # Fucking typos
        New-Alias -Name nvi  -Value 'nvim.exe' -ErrorAction SilentlyContinue;
        New-Alias -Name vnim -Value 'nvim.exe' -ErrorAction SilentlyContinue;

    }

    New-Alias -Name bi -Value 'vi' -ErrorAction SilentlyContinue;
    New-Alias -Name ci -Value 'vi' -ErrorAction SilentlyContinue;
}
else {
    function cdvim {
        cd "$HOME\vimfiles";
    }

    function cdvi {
        cd "$HOME\vimfiles\";
    }
}

New-Alias -Name open -Value 'ii'

if (Get-Command "bat" -ErrorAction SilentlyContinue) {
    New-Alias -Name cat -Value 'bat' -ErrorAction SilentlyContinue;
    $env:GIT_PAGER = "bat.exe";
}

if (Get-Command "delta" -ErrorAction SilentlyContinue) {
    $env:GIT_PAGER = 'delta --dark --24-bit-color always';
}

if ( Get-Command "fzf.exe" -ErrorAction SilentlyContinue ) {

    if ( Get-Command "git.exe" -ErrorAction SilentlyContinue ) {
        if ( Get-Command "fd.exe" -ErrorAction SilentlyContinue ) {
            $env:FZF_DEFAULT_COMMAND = '(git --no-pager ls-files -co --exclude-standard || fd --type f --hidden --follow --color always -E "*.spl" -E "*.aux" -E "*.out" -E "*.o" -E "*.pyc" -E "*.gz" -E "*.pdf" -E "*.sw" -E "*.swp" -E "*.swap" -E "*.com" -E "*.exe" -E "*.so" -E "*/cache/*" -E "*/__pycache__/*" -E "*/tmp/*" -E ".git/*" -E ".svn/*" -E ".xml" -E "*.bin" -E "*.7z" -E "*.dmg" -E "*.gz" -E "*.iso" -E "*.jar" -E "*.rar" -E "*.tar" -E "*.zip" -E "TAGS" -E "tags" -E "GTAGS" -E "COMMIT_EDITMSG" . . ) 2> nul';
            $env:FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
            $env:FZF_ALT_C_COMMAND = "fd --color always -t d . $HOME";
        }
        elseif ( Get-Command "rg.exe" -ErrorAction SilentlyContinue ) {
            $env:FZF_DEFAULT_COMMAND = "(git --no-pager ls-files -co --exclude-standard || rg --line-number --column --with-filename --color always --no-search-zip --hidden --trim --files ) 2> nul";
            $env:FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
        }
        elseif ( Get-Command "ag.exe" -ErrorAction SilentlyContinue ) {
            $env:FZF_DEFAULT_COMMAND = "(git --no-pager ls-files -co --exclude-standard || ag -l --follow --color --nogroup --hidden -g '') 2> nul";
            $env:FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
        }
    }
    else {
        if ( Get-Command "fd.exe" -ErrorAction SilentlyContinue ) {
            $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --color always -E "*.spl" -E "*.aux" -E "*.out" -E "*.o" -E "*.pyc" -E "*.gz" -E "*.pdf" -E "*.sw" -E "*.swp" -E "*.swap" -E "*.com" -E "*.exe" -E "*.so" -E "*/cache/*" -E "*/__pycache__/*" -E "*/tmp/*" -E ".git/*" -E ".svn/*" -E ".xml" -E "*.bin" -E "*.7z" -E "*.dmg" -E "*.gz" -E "*.iso" -E "*.jar" -E "*.rar" -E "*.tar" -E "*.zip" -E "TAGS" -E "tags" -E "GTAGS" -E "COMMIT_EDITMSG" . . 2> nul';
            $env:FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
            $env:FZF_ALT_C_COMMAND = "fd --color always -t d . $HOME";
        }
        elseif ( Get-Command "rg.exe" -ErrorAction SilentlyContinue ) {
            $env:FZF_DEFAULT_COMMAND = "rg --line-number --column --with-filename --color always --no-search-zip --hidden --trim --files 2> nul";
            $env:FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
        }
        elseif ( Get-Command "ag.exe" -ErrorAction SilentlyContinue ) {
            $env:FZF_DEFAULT_COMMAND = "ag -l --follow --color --nogroup --hidden -g ''2> nul";
            $env:FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
        }
    }

    $env:FZF_DEFAULT_OPTS = '--layout=reverse --border --ansi';

    if ( Get-Command "nvim.exe" -ErrorAction SilentlyContinue ) {
        function fe {
            $files = @(fzf --height 70% --query="$1" --multi --select-1 --exit-0);
            if ($files.Length -gt 0) {
                nvim $files;
            }
        }
    }

}

if ( Get-Command "thefuck.exe" -ErrorAction SilentlyContinue ) {
    iex "$(thefuck --alias)";
}
