# Add auto-completion and a stored history file of commands to your Python
# interactive interpreter. Requires Python 2.0+, readline. Autocomplete is
# bound to the Esc key by default (you can change it - see readline docs).
#
# Store the file where you want and set environment variable to point
# to it:  export PYTHONSTARTUP="$HOME/path/to/the/file" in your ${SHELL}rc
# Normally .bashrc or .zshrc

import atexit
import os
import sys

readline = None

try:
    import pyreadline

    readline = pyreadline
except ImportError:
    try:
        import readline as _readline
        import rlcompleter  # noqa

        readline = _readline
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
        exit()

    def __str__(self):
        return "Quit object to quick quit current prompt"


q = Quit()
home = "HOME" if os.name != "nt" else "USERPROFILE"
history_file = os.path.join(os.environ[home], ".pyhistory")

if not os.path.exists(history_file):
    open(history_file, "a").close()

if readline is not None:

    def rl_autoindent():
        """
        Auto-indent upon typing a new line according to the contents of the
        previous line.  This function will be used as Readline's
        pre-input-hook.
        """
        try:
            import readline
        except ImportError:
            return

        hist_len = readline.get_current_history_length()
        last_input = readline.get_history_item(hist_len)
        indent = ""

        try:
            last_indent_index = last_input.rindex("    ")
            last_indent = int(last_indent_index / 4) + 1
        except Exception:
            last_indent = 0

        if len(last_input.strip()) > 1:
            if last_input.count("(") > last_input.count(")"):
                indent = "".join(["    " for _ in range(last_indent + 2)])
            elif last_input.count(")") > last_input.count("("):
                indent = "".join(["    " for _ in range(last_indent - 1)])
            elif last_input.count("[") > last_input.count("]"):
                indent = "".join(["    " for _ in range(last_indent + 2)])
            elif last_input.count("]") > last_input.count("["):
                indent = "".join(["    " for _ in range(last_indent - 1)])
            elif last_input.count("{") > last_input.count("}"):
                indent = "".join(["    " for _ in range(last_indent + 2)])
            elif last_input.count("}") > last_input.count("{"):
                indent = "".join(["    " for _ in range(last_indent - 1)])
            elif last_input[-1] == ":":
                indent = "".join(["    " for _ in range(last_indent + 1)])
            else:
                indent = "".join(["    " for _ in range(last_indent)])
        readline.insert_text(indent)

    try:
        readline.read_history_file(history_file)
        # readline.set_pre_input_hook(rl_autoindent)
        readline.parse_and_bind("tab: complete")
        readline.set_history_length(1000)
        atexit.register(readline.write_history_file, history_file)
    except IOError:
        print("Could not open {}".format(history_file))
    except AttributeError:
        # Pyreadline is old and not longer mainteined so It doesn't have most
        # of the functions readline module does, sooo we just silently fail
        # here
        pass

del os, sys, readline, atexit, history_file, home
