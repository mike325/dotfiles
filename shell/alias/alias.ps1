New-Alias -Name nvr -Value $env:USERPROFILE'\AppData\Roaming\Python\Python36\Scripts\nvr.exe'
New-Alias -Name cl -Value 'cls'

# TODO: Check if the program exists
function vi {
    nvr --remote-silent $args
}

function vim {
    nvr --remote-silent $args
}

function nvim {
    nvr --remote-silent $args
}
