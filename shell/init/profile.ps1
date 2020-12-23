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


$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
$MaximumHistoryCount = 10000;

if ($env:SHELL -eq $null) {
    $env:SHELL = 'powershell'
}

if ( -Not (Get-Command "which" -ErrorAction SilentlyContinue) ) {
    function which($name) {
        Get-Command $name | Select-Object -ExpandProperty Definition
    }
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
    New-Item -Target $target -ItemType SymbolicLink -Path $link
}

# Path settings
if ( Test-Path "$env:USERPROFILE\.local\bin" ) {
    $env:path = "$env:USERPROFILE\.local\bin;$env:path"
}

# Path settings
if ( Test-Path "$env:USERPROFILE\scoop\shims" ) {
    $env:path = "$env:USERPROFILE\scoop\shims;$env:path"
}

if ( Test-Path "$env:APPDATA\Neovim\bin" ) {
    $env:path = "$env:APPDATA\Neovim\bin;$env:path"
}

if (Test-Path "$env:APPDATA\Python\Python27\Scripts") {
    $env:path = "$env:APPDATA\Python\Python27\Scripts;$env:path"
}

# NOTE: It's better to install python with scoop and use versions to manage it
# $python_versions = @('9', '8', '7', '6', '5', '4', '3')
# foreach($version in $python_versions) {
#     if (Test-Path "$env:APPDATA\Python\Python3$version\Scripts") {
#         $env:path = "$env:APPDATA\Python\Python3$version\Scripts;$env:path"
#     }
# }

if ( Test-Path "$env:USERPROFILE\.local\lib\pythonstartup.py") {
    $env:PYTHONSTARTUP = "$env:USERPROFILE\.local\lib\pythonstartup.py"
}

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Write-Git-Branch {
    Invoke-Expression "git symbolic-ref --short HEAD" 2> $null | Tee-Object -Variable branch | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " | $branch | " -NoNewline -ForegroundColor blue
    }
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

    Write-Host ": " -NoNewline -ForegroundColor DarkGray
    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~") -NoNewline -ForegroundColor Yellow


    if (Get-Command "git" -ErrorAction SilentlyContinue) {
        Write-Git-Branch
    }

    $global:LASTEXITCODE = $realLASTEXITCODE

    Write-Host ""

    return "$ "
}

$powersource = "$env:USERPROFILE\.config\shell\host\proxy.ps1"
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
            . "$env:USERPROFILE\.config\shell\host\proxy.ps1"
            Write-Host " Proxy enable"
        }
    }
}

$powersource = "$env:USERPROFILE\.config\shell\alias\alias.ps1"
if (Test-Path($powersource)) {
    . $powersource
}

$powersource = "$env:USERPROFILE\.config\shell\host\env.ps1"
if (Test-Path($powersource)) {
    . $powersource
}

$powersource = "$env:USERPROFILE\.config\shell\host\alias.ps1"
if (Test-Path($powersource)) {
    . $powersource
}

$powersource = "$env:USERPROFILE\.config\shell\host\settings.ps1"
if (Test-Path($powersource)) {
    . $powersource
}

if ($env:VIRTUAL_ENV -ne $null) {
    . "$env:VIRTUAL_ENV\Scripts\activate.ps1"
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

Import-Module PSReadLine -ErrorAction SilentlyContinue

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
