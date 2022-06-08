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
# [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# [Console]::InputEncoding = [System.Text.Encoding]::UTF8
# $OutputEncoding = [System.Text.UTF8Encoding]::new()
# $OutputEncoding = [ System.Text.Encoding]::UTF8
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$MaximumHistoryCount = 10000;

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
if (Test-Path "$env:APPDATA\Python\Python27\Scripts") {
    $env:path = "$env:APPDATA\Python\Python27\Scripts;$env:path"
}

if ( Test-Path "$env:USERPROFILE\.local\bin" ) {
    $env:path = "$env:USERPROFILE\.local\bin;$env:path"
}

if ( Test-Path "$env:USERPROFILE\scoop\shims" ) {
    $env:path = "$env:USERPROFILE\scoop\shims;$env:path"
}

if ( Test-Path "$env:USERPROFILE\.cargo\bin" ) {
    $env:path = "$env:USERPROFILE\.cargo\bin;$env:path"
}

if ( Test-Path "$env:APPDATA\Neovim\bin" ) {
    $env:path = "$env:APPDATA\Neovim\bin;$env:path"
}

if ( Test-Path "$env:APPDATA\LuaRocks\bin" ) {
    $env:path = "$env:APPDATA\LuaRocks\bin;$env:path"
}

# NOTE: It's better to install python with scoop and use versions to manage it
$python_versions = @('12', '11', '10', '9', '8', '7', '6')
foreach($version in $python_versions) {
    if (Test-Path "$env:APPDATA\Python\Python3$version\Scripts") {
        $env:path = "$env:APPDATA\Python\Python3$version\Scripts;$env:path"
        break
    }
}

if ( Test-Path "$env:USERPROFILE\.local\lib\pythonstartup.py") {
    $env:PYTHONSTARTUP = "$env:USERPROFILE\.local\lib\pythonstartup.py"
}

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Write-Git-Info {
    Invoke-Expression "git symbolic-ref --short HEAD" 2> $null | Tee-Object -Variable branch | Out-Null
    if ($LASTEXITCODE -eq 0) {
        (Invoke-Expression "git stash list" 2> $null | Measure-Object -Line).Lines | Tee-Object -Variable stash | Out-Null
        # Invoke-Expression "git diff --shortstat" 2> $null | Tee-Object -Variable changes | Out-Null
        # Invoke-Expression "git diff --cached --shortstat" 2> $null | Tee-Object -Variable to_commit | Out-Null

        Write-Host " | " -NoNewline -ForegroundColor Blue
        Write-Host "$branch " -NoNewline -ForegroundColor Blue
        # if ($to_commit -ne $null) {
        #     $files_staged = $to_commit.split(' ')[1]
        #     Write-Host "*$files_staged " -NoNewline -ForegroundColor Magenta
        # }
        # if ($changes -ne $null) {
        #     $changes = $changes.split(',')
        #     $files_changed = $changes[0].split(' ')[1]
        #     $changes_message = "~$files_changed"
        #     Write-Host "$changes_message " -NoNewline -ForegroundColor DarkYellow
        # }
        if ($stash -gt 0) {
            Write-Host "{$stash} " -NoNewline -ForegroundColor Yellow
        }
        Write-Host "| " -NoNewline -ForegroundColor Blue
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

    # if ($realLASTEXITCODE -ne 0) {
    #     Write-Host "❌ " -NoNewline -ForegroundColor DarkRed
    # }

    Write-Host "$env:USERNAME" -NoNewline -ForegroundColor Magenta
    Write-Host " at " -NoNewline -ForegroundColor White
    Write-Host "$env:COMPUTERNAME" -NoNewline -ForegroundColor Cyan

    if ($s -ne $null) {  # color for PSSessions
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ") " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host ": " -NoNewline -ForegroundColor White
    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~") -NoNewline -ForegroundColor Yellow

    if ($env:http_proxy -ne $null) {
        Write-Host " -P-" -NoNewline -ForegroundColor Green
    }

    # if ($env:VIRTUAL_ENV -ne $null) {
    #     # Python Virtual environment
    #     # Write-Host " 🌐 " -NoNewline -ForegroundColor Green
    # }

    if (Get-Command "git" -ErrorAction SilentlyContinue) {
        Write-Git-Info
    }

    Write-Host ""

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "$ "
}

$powersource = "$env:USERPROFILE\.config\shell\host\proxy.ps1"
if (Test-Path($powersource)) {
    . $powersource
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

Remove-Item Env:\TERM -ErrorAction SilentlyContinue

Import-Module posh-git -ErrorAction SilentlyContinue
Import-Module PSReadLine -ErrorAction SilentlyContinue

# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue
Set-PSReadlineKeyHandler -Key Ctrl+p -Function HistorySearchBackward -ErrorAction SilentlyContinue
Set-PSReadlineKeyHandler -Key Ctrl+n -Function HistorySearchForward -ErrorAction SilentlyContinue

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
