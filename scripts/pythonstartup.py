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
history_file = os.path.join(os.environ['HOME'], '.pyhistory')

try:

    def rl_autoindent():
        """
        Auto-indent upon typing a new line according to the contents of the
        previous line.  This function will be used as Readline's
        pre-input-hook.
        """
        try:
            import readline
        except ImportError:
            try:
                import pyreadline as readline
            except ImportError:
                return
        hist_len = readline.get_current_history_length()
        last_input = readline.get_history_item(hist_len)
        indent = ''
        try:
            last_indent_index = last_input.rindex("    ")
        except Exception:
            last_indent = 0
        else:
            last_indent = int(last_indent_index / 4) + 1
        if len(last_input.strip()) > 1:
            if last_input.count("(") > last_input.count(")"):
                indent = ''.join(["    " for n in range(last_indent + 2)])
            elif last_input.count(")") > last_input.count("("):
                indent = ''.join(["    " for n in range(last_indent - 1)])
            elif last_input.count("[") > last_input.count("]"):
                indent = ''.join(["    " for n in range(last_indent + 2)])
            elif last_input.count("]") > last_input.count("["):
                indent = ''.join(["    " for n in range(last_indent - 1)])
            elif last_input.count("{") > last_input.count("}"):
                indent = ''.join(["    " for n in range(last_indent + 2)])
            elif last_input.count("}") > last_input.count("{"):
                indent = ''.join(["    " for n in range(last_indent - 1)])
            elif last_input[-1] == ":":
                indent = ''.join(["    " for n in range(last_indent + 1)])
            else:
                indent = ''.join(["    " for n in range(last_indent)])
        readline.insert_text(indent)

    try:
        readline.read_history_file(history_file)
    except IOError:
        pass

    readline.set_pre_input_hook(rl_autoindent)
    readline.parse_and_bind("tab: complete")
    readline.set_history_length(1000)
    atexit.register(readline.write_history_file, history_file)

except NameError:
    pass
finally:
    del os, sys, readline, rlcompleter, atexit, history_file
