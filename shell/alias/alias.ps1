# Author: Mike 8a
# Description: Some useful alias and functions
# github.com/mike325/dotfiles

New-Alias -Name cl -Value 'cls' -ErrorAction SilentlyContinue;
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

New-Alias -Name open -Value 'ii' -ErrorAction SilentlyContinue;

if (Get-Command "bat" -ErrorAction SilentlyContinue) {
    del alias:cat -ErrorAction SilentlyContinue;
    New-Alias -Name cat -Value 'bat' -ErrorAction SilentlyContinue;
    $env:GIT_PAGER = "bat.exe";
}
else {
    New-Alias -Name cat -Value 'Get-Content' -ErrorAction SilentlyContinue;
}

if (Get-Command "coreutils" -ErrorAction SilentlyContinue) {
    $cmd_alias = @(
        'pwd',
        # This are read-only alias, may need "sudo" to remove them
        # 'sleep',
        # 'sort',
        # 'tee',
        'ls',
        'cp',
        'mv',
        'rm'
    )
    $cmd_alias | foreach {
        if (Test-Path Alias:$_) {Remove-Item Alias:$_}
    }

    if (-not (Get-Command basename -ErrorAction SilentlyContinue)) { function basename() { coreutils basename $args;}}
    if (-not (Get-Command cp       -ErrorAction SilentlyContinue)) { function cp() { coreutils cp $args;}}
    if (-not (Get-Command cut      -ErrorAction SilentlyContinue)) { function cut() { coreutils cut $args;}}
    if (-not (Get-Command df       -ErrorAction SilentlyContinue)) { function df() { coreutils df $args;}}
    if (-not (Get-Command head     -ErrorAction SilentlyContinue)) { function head() { coreutils head $args;}}
    if (-not (Get-Command ln       -ErrorAction SilentlyContinue)) { function ln() { coreutils ln $args;}}
    if (-not (Get-Command ls       -ErrorAction SilentlyContinue)) { function ls() { coreutils ls $args;}}
    if (-not (Get-Command la       -ErrorAction SilentlyContinue)) { function la() { coreutils ls -A $args;}}
    if (-not (Get-Command ll       -ErrorAction SilentlyContinue)) { function ll() { coreutils ls -lhA $args;}}
    if (-not (Get-Command mkdir    -ErrorAction SilentlyContinue)) { function mkdir() { coreutils mkdir $args;}}
    if (-not (Get-Command more     -ErrorAction SilentlyContinue)) { function more() { coreutils more $args;}}
    if (-not (Get-Command mv       -ErrorAction SilentlyContinue)) { function mv() { coreutils mv $args;}}
    if (-not (Get-Command pwd      -ErrorAction SilentlyContinue)) { function pwd() { coreutils pwd $args;}}
    if (-not (Get-Command readlink -ErrorAction SilentlyContinue)) { function readlink() { coreutils readlink $args;}}
    if (-not (Get-Command realpath -ErrorAction SilentlyContinue)) { function realpath() { coreutils realpath $args;}}
    if (-not (Get-Command rm       -ErrorAction SilentlyContinue)) { function rm() { coreutils rm $args;}}
    if (-not (Get-Command tail     -ErrorAction SilentlyContinue)) { function tail() { coreutils tail $args;}}
    if (-not (Get-Command tr       -ErrorAction SilentlyContinue)) { function tr() { coreutils tr $args;}}
    if (-not (Get-Command uniq     -ErrorAction SilentlyContinue)) { function uniq() { coreutils uniq $args;}}
    if (-not (Get-Command wc       -ErrorAction SilentlyContinue)) { function wc() { coreutils wc $args;}}

    # if (-not (Get-Command tee      -ErrorAction SilentlyContinue)) {function tee() { coreutils tee $args;}}
    # if (-not (Get-Command sleep    -ErrorAction SilentlyContinue)) {function sleep() { coreutils sleep $args;}}
    # if (-not (Get-Command sort     -ErrorAction SilentlyContinue)) {function sort() { coreutils sort $args;}}
}
else {
    New-Alias -Name ll -Value 'ls' -ErrorAction SilentlyContinue;
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
        else {
            $env:FZF_DEFAULT_COMMAND = "(git --no-pager ls-files -co --exclude-standard || powershell.exe -NoLogo -NoProfile -Noninteractive -Command 'Get-ChildItem -File -Recurse -Name') 2> nul";
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
        else {
            $env:FZF_DEFAULT_COMMAND = 'powershell.exe -NoLogo -NoProfile -Noninteractive -Command "Get-ChildItem -File -Recurse -Name"';
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

if (Test-Path("$env:USERPROFILE\.config\shell\host\proxy.ps1")) {
    function toggleProxy {
        $proxy = "$env:USERPROFILE\.config\shell\host\proxy.ps1"
        if ($env:http_proxy -ne $null -AND $env:http_proxy -ne '') {
            Remove-Item env:\http_proxy -ErrorAction SilentlyContinue
            Remove-Item env:\https_proxy -ErrorAction SilentlyContinue
            Remove-Item env:\ftp_proxy -ErrorAction SilentlyContinue
            Remove-Item env:\socks_proxy -ErrorAction SilentlyContinue
            Remove-Item env:\no_proxy -ErrorAction SilentlyContinue
            if (Test-Administrator) {
                Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Hyper"} | Set-NetIPInterface -InterfaceMetric 5000 -ErrorAction SilentlyContinue;
                Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco"} | Set-NetIPInterface -InterfaceMetric 1 -ErrorAction SilentlyContinue;
            }
            Write-Host " Proxy disable" -ForegroundColor Yellow
        }
        elseif (Test-Path($proxy)) {
            . "$env:USERPROFILE\.config\shell\host\proxy.ps1"
            if (Test-Administrator) {
                Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Hyper"} | Set-NetIPInterface -InterfaceMetric 1 -ErrorAction SilentlyContinue;
                Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco"} | Set-NetIPInterface -InterfaceMetric 5000 -ErrorAction SilentlyContinue;
            }
            Write-Host " Proxy enable" -ForegroundColor Green
        }
        else {
            Write-Host " Missing proxy file at $proxy" -ForegroundColor Red
        }
    }
}
