# Dotfiles

[![Travis Status](https://travis-ci.com/Mike325/dotfiles.svg?branch=master)](https://travis-ci.com/Mike325/dotfiles)
[![Github Status](https://github.com/Mike325/dotfiles/workflows/dotfiles/badge.svg)](https://github.com/Mike325/dotfiles/actions)

Here are most of my dotfiles. Since my Vim settings are quite big, I prefer to
have them in a different [repo](https://github.com/mike325/.vim),
Same goes for my Emacs settings [here](https://github.com/mike325/.emacs.d)

Feel free to make comments about my configuration and of course take anything
you want or find useful.

You can test some of the settings by linking then in your `$HOME`

```sh
ln -s $(readlink -f ./shell/shellrc) ~/.bashrc
ln -s $(readlink -f ./git/gitconfig) ~/.gitconfig
```

If you prefer to test some specific "modules" I recommend you to use my simple
install script.

```sh
./install.sh --force           # To force install by removing all previous files
./install.sh --git             # To install Git settings
./install.sh --vim --shell     # To install Vim dotfiles and shell alias
./install.sh --bin --portables # Install bin binaries and download portable programs
./install.sh --backup          # To backup all files before install dotfiles
./install.sh --help            # To get all the
```

!!! WARNING  !!!
Since I like to install everything, the default configuration `./install` tries
to install all my dotfiles, this is disable whenever a specific module is pass
as and argument
