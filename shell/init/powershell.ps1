################################################################################
#                                                                              #
#   Author: Mike 8a                                                            #
#   Description: Some useful alias and functions                               #
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


New-Alias -Name cl -Value 'cls' -ErrorAction SilentlyContinue
New-Alias -Name ll -Value 'ls' -ErrorAction SilentlyContinue
New-Alias -Name unset -Value 'Remove-Item' -ErrorAction SilentlyContinue

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function q {
    exit
}

function touch {
    New-Item -path $args -type file
}

if ( Get-Command "nvim.exe" -ErrorAction SilentlyContinue) {
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
        $env:GIT_PAGER = "nvr.exe -cc 'setlocal modifiable' -c 'setlocal ft=git nomodifiable' --remote-tab -"
        $env:EDITOR    = "nvr.exe --remote-tab-wait"

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

# Typos
if (Get-Command "git" -ErrorAction SilentlyContinue) {
    New-Alias -Name gti -Value 'git' -ErrorAction SilentlyContinue
    New-Alias -Name got -Value 'git' -ErrorAction SilentlyContinue
    New-Alias -Name gut -Value 'git' -ErrorAction SilentlyContinue
    # New-Alias -Name gi  -Value 'git' -ErrorAction SilentlyContinue
}

# Path settings
if ( Test-Path "$HOME\.local\bin" ) {
    $env:path = "$HOME\.local\bin;$env:path"
}

# $pythonscripts

if (Test-Path "$HOME\AppData\Roaming\Python\Python27\Scripts") {
    $env:path = "$HOME\AppData\Roaming\Python\Python27\Scripts;$env:path"
}

$python_versions = @('8', '7', '6', '5', '4', '3')
foreach($version in $python_versions) {
    if (Test-Path "$HOME\AppData\Roaming\Python\Python3$version\Scripts") {
        $env:path = "$HOME\AppData\Roaming\Python\Python3$version\Scripts;$env:path"
    }
}

if ( Test-Path "$HOME\.local\lib\pythonstartup.py") {
    $env:PYTHONSTARTUP = "$env:USERPROFILE\.local\lib\pythonstartup.py"
}

if ($env:PYTHONPATH -eq $null) {
    $env:PYTHONPATH = "$env:USERPROFILE\cdf_engines;c:\PythonSv"
}
else {
    $env:PYTHONPATH = "$env:USERPROFILE\cdf_engines;c:\PythonSv;$env:PYTHONPATH"
}

if (Get-Command "python" -ErrorAction SilentlyContinue) {
    New-Alias -Name py  -Value 'python'  -ErrorAction SilentlyContinue
}

if (Get-Command "python2" -ErrorAction SilentlyContinue) {
    New-Alias -Name py2 -Value 'python2' -ErrorAction SilentlyContinue
}

if (Get-Command "python3" -ErrorAction SilentlyContinue) {
    New-Alias -Name py3 -Value 'python3' -ErrorAction SilentlyContinue
}

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host

    # Reset color, which can be messed up by Enable-GitColors
    # $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    if (Test-Administrator) {  # Use different username if elevated
        Write-Host "(Elevated) " -NoNewline -ForegroundColor Red
    }

    Write-Host "$ENV:USERNAME" -NoNewline -ForegroundColor Magenta
    Write-Host " at " -NoNewline -ForegroundColor White
    Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor Cyan

    if ($s -ne $null) {  # color for PSSessions
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ") " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host " in " -NoNewline -ForegroundColor DarkGray
    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~") -NoNewline -ForegroundColor Yellow
    # Write-Host " : " -NoNewline -ForegroundColor DarkGray
    # Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkMagenta
    # Write-Host " : " -NoNewline -ForegroundColor DarkGray

    $global:LASTEXITCODE = $realLASTEXITCODE

    # Write-VcsStatus

    Write-Host ""

    return "$ "
}

$proxy = "$HOME\.config\shell\host\proxy.ps1"
if (Test-Path($proxy)) {
    . $proxy
}

$settings = "$HOME\.config\shell\host\settings.ps1"
if (Test-Path($settings)) {
    . $settings
}

Write-Host "
                               -'
               ...            .o+'
            .+++s+   .h'.    'ooo/
           '+++%++  .h+++   '+oooo:
           +++o+++ .hhs++. '+oooooo:
           +s%%so%.hohhoo'  'oooooo+:
           '+ooohs+h+sh++'/:  ++oooo+:
            hh+o+hoso+h+'/++++.+++++++:
             '+h+++h.+ '/++++++++++++++:
                      '/+++ooooooooooooo/'
                     ./ooosssso++osssssso+'
                    .oossssso-''''/osssss::'
                   -osssssso.      :ssss''to.
                  :osssssss/  Mike  osssl   +
                 /ossssssss/   8a   +sssslb
               '/ossssso+/:-        -:/+ossss'.-
              '+sso+:-'                 '.-/+oso:
             '++:.                           '-/+/
             .'   github.com/mike325/dotfiles   '/
"

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
