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


function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function q {
    if ( Get-Command "deactivate" -ErrorAction SilentlyContinue ) {
        deactivate
    }
    else {
        exit
    }
}

function touch {
    New-Item -path $args -type file
}

function ln ($target, $link) {
    New-Item -Path $link -ItemType SymbolicLink -Value $target
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

$powersource = "$HOME\.config\shell\host\proxy.ps1"
if (Test-Path($powersource)) {
    . $powersource
    function toggleProxy {
        if ($env:http_proxy -ne $null -AND $env:http_proxy -ne '') {
            Remove-Item env:\http_proxy
            Remove-Item env:\https_proxy
            Remove-Item env:\ftp_proxy
            Remove-Item env:\socks_proxy
            Remove-Item env:\no_proxy
            Write-Host " Proxy disable"
        }
        else {
            . "$HOME\.config\shell\host\proxy.ps1"
            Write-Host " Proxy enable"
        }
    }
}

$powersource = "$HOME\.config\shell\alias\alias.ps1"
if (Test-Path($powersource)) {
    . $powersource
}

$powersource = "$HOME\.config\shell\host\env.ps1"
if (Test-Path($powersource)) {
    . $powersource
}

$powersource = "$HOME\.config\shell\host\alias.ps1"
if (Test-Path($powersource)) {
    . $powersource
}

$powersource = "$HOME\.config\shell\host\settings.ps1"
if (Test-Path($powersource)) {
    . $powersource
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
