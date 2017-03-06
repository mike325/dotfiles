# Add auto-completion and a stored history file of commands to your Python
# interactive interpreter. Requires Python 2.0+, readline. Autocomplete is
# bound to the Esc key by default (you can change it - see readline docs).
#
# Store the file where you want and set environment variable to point
# to it:  export PYTHONSTARTUP="$HOME/path/to/the/file" in your ${SHELL}rc
# Normally .bashrc or .zshrc

import atexit
import os
import readline
import rlcompleter

__header__ = """
                                     -`
                     ...            .o+`
                  .+++s+   .h+     `ooo/
                 `+++%++  .h+++   `+oooo:
                 +++o+++ .hhs++o `+oooooo:
                 +s%%so%.hohhooo -+oooooo+:
                 `+ooohs+h+sh++`/:-:++oooo+:
                  hh+o+hoso+h+`/++++/+++++++:
                   `+h+++h.+ `/++++++++++++++:
                            `/+++ooooooooooooo/`
                           ./ooosssso++osssssso+`
                          .oossssso-````/ossssss+`
                         -osssssso.      :ssssssso.
                        :osssssss/  Mike  osssso+++.
                       /ossssssss/   8a   +ssssooo/-
                     `/ossssso+/:-        -:/+osssso+-
                    `+sso+:-`                 `.-/+oso:
                   `++:.                           `-/+/
                   .`                                 `/
"""

print(__header__)

readline.parse_and_bind("tab: complete")
historyPath = os.path.expanduser("~/.pyhistory")

def q():
    exit()

def save_history(historyPath=historyPath):
    import readline
    readline.write_history_file(historyPath)

if os.path.exists(historyPath):
    readline.read_history_file(historyPath)

atexit.register(save_history)
del os, atexit, readline, rlcompleter, save_history, historyPath
