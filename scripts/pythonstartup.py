# Add auto-completion and a stored history file of commands to your Python
# interactive interpreter. Requires Python 2.0+, readline. Autocomplete is
# bound to the Esc key by default (you can change it - see readline docs).
#
# Store the file where you want and set environment variable to point
# to it:  export PYTHONSTARTUP="$HOME/path/to/the/file" in your ${SHELL}rc
# Normally .bashrc or .zshrc

from __future__ import unicode_literals
from __future__ import print_function
from __future__ import with_statement
from __future__ import division

import atexit
import os
import sys
import rlcompleter

try:
    import readline
except ImportError:
    try:
        import pyreadline as readline
    except ImportError:
        print("Error importing readline and pyreadline modules")

__header__ = """
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
             .'                                 '/
"""

sys.ps1 = "Mike >>> "
sys.ps2 = "Mike ... "

print(__header__)


class Quit(object):
    def __init__(self):
        super(Quit, self).__init__()

    def __repr__(self):
        exit(0)

    def __str__(self):
        return 'Quit object to quick quit current prompt'

    def __call__(self):
        exit(0)


q = Quit()
historyPath = os.path.expanduser("~/.pyhistory")
try:

    def save_history(historyPath=historyPath):
        try:
            import readline
        except ImportError:
            try:
                import pyreadline as readline
            except ImportError:
                return
        try:
            readline.write_history_file(historyPath)
        except OSError:
            print('Failed to write history file, please check the file has permisions to be written or it is not hidden (Windows)')

    if os.path.exists(historyPath):
        readline.read_history_file(historyPath)

    readline.parse_and_bind("tab: complete")

    atexit.register(save_history)
    del readline
except NameError:
    pass
finally:
    del os, atexit, rlcompleter, save_history, historyPath, sys
