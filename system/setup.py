#!/usr/bin/env python

from __future__ import unicode_literals
from __future__ import print_function
from __future__ import with_statement
from __future__ import division
import platform
import argparse
import json
from subprocess import call

__header__ = """
                              -`
              ...            .o+`
           .+++s+   .h`.    `ooo/
          `+++%++  .h+++   `+oooo:
          +++o+++ .hhs++. `+oooooo:
          +s%%so%.hohhoo'  'oooooo+:
          `+ooohs+h+sh++`/:  ++oooo+:
           hh+o+hoso+h+`/++++.+++++++:
            `+h+++h.+ `/++++++++++++++:
                     `/+++ooooooooooooo/`
                    ./ooosssso++osssssso+`
                   .oossssso-````/osssss::`
                  -osssssso.      :ssss``to.
                 :osssssss/  Mike  osssl   +
                /ossssssss/   8a   +sssslb
              `/ossssso+/:-        -:/+ossss'.-
             `+sso+:-`                 `.-/+oso:
            `++:.                           `-/+/
            .`                                 `/
"""

_PKGS = {
    # Global packages (any Unix system, may support windows Cywing later)
    # All global packages will be install using main method
    "global": [
        "curl",
        "git",
        "wget",
        "gcc",
        "make",
        "sed",
        "htop",
        "cmake",
        "ctags",
        "sl",
        "unzip",
    ],
    "arch": {
        "main": {
            "name": "pacman",
            "args": "-S",
            "sudo": True,
            "pkgs": [
                "base-devel",
                "python-pip",
                "python2-pip",
                "neovim",
                "docker",
                "clang",
                "jdk8-openjdk",
                "the_silver_searcher",
                "shellcheck",
            ],
        },
        "secondary": {
            "name": "yaourt",
            "args": "-S",
            "sudo": False,
            "pkgs": [
                "spotify",
                "libtinfo",  # YCM Required
                "ncurses5-compat-libs",  # YCM Required
                "arc-gtk-theme",
                "arc-firefox-theme",
                "jdk",
                "nextcloud-client",
            ],
        },
    },
    "debian": {
        "main": {
            "name": "apt",
            "args": "install",
            "sudo": True,
            "pkgs": [
                "vim-nox",
                "python-dev",
                "python3-dev",
                "pkg-config",
                "aptitude",
                "g++",
                "libtool",
                "libtool-bin",
                "autoconf",
                "automake",
                "shellcheck",
            ],
        },
    },
    "ubuntu": {
        "main": {
            "name": "apt",
            "args": "install",
            "sudo": True,
            "pkgs": [  # TODO: May add version with PPA
                "pkg-config",
                "aptitude",
                "g++",
                "libtool",
                "libtool-bin",
                "autoconf",
                "automake",
                "build-essential",
                "shellcheck",
            ],
        },
    },
    "fedora": {
        "main": {
            "name": "dnf",
            "args": "install",
            "sudo": True,
            "pkgs": [
                "libtool",
                "autoconf",
                "automake",
                "gcc-c++",
                "pkgconfig",
                "ShellCheck",
            ],
        },
    },
}


def status_message(message):
    """TODO: Docstring for status_message.

    :message: TODO
    :returns: TODO

    """
    print("[*]  {0}".format(message))


def warning_message(message):
    """TODO: Docstring for status_message.

    :message: TODO
    :returns: TODO

    """
    print("[!]  ---- Warning: {0}".format(message))


def error_message(message):
    """TODO: Docstring for status_message.

    :message: TODO
    :returns: TODO

    """
    print("[X]  ---- Error: {0}".format(message))


class PkgManager(object):
    """ Manager for the package to be install """

    def __init__(self, data=None):
        """
        :data: JSON with the package install format
        """
        global _PKGS
        super(PkgManager, self).__init__()
        self._python_version = list(platform.python_version_tuple())
        self._name = list(platform.dist())[0]
        self._version = list(platform.dist())[1]
        self._arch = platform.machine()
        # self._desktop = ""
        self._global_pkgs = None

        if data is not None:
            # Set default values if the json data doesn't provide the elements
            self._python_version = data["python_version"] if "python_version" in data else self._python_version
            self._name = data["name"] if "name" in data else self._name
            self._version = data["version"] if "version" in data else self._version
            self._arch = data["arch"] if "arch" in data else self._arch

            self._main_tool = {
                "name": data["main"]["name"],
                "args": data["main"]["args"],
                "sudo": data["main"]["sudo"],
                "pkgs": data["main"]["pkgs"]
            }

            if "global" in data:
                self._global_pkgs = data["global"]
                self._main_tool["pkgs"] += self._global_pkgs

            self._secondary_tool = None
            if "secondary" in data:
                self._secondary_tool = {
                    "name": data["secondary"]["name"],
                    "args": data["secondary"]["args"],
                    "sudo": data["secondary"]["sudo"],
                    "pkgs": data["secondary"]["pkgs"]
                }
        else:

            if self._name not in _PKGS.keys():
                raise ValueError(self._name)

            self._global_pkgs = _PKGS["global"]

            self._main_tool = {
                "name": _PKGS[self._name]["main"]["name"],
                "args": _PKGS[self._name]["main"]["args"],
                "sudo": _PKGS[self._name]["main"]["sudo"],
                "pkgs": _PKGS[self._name]["main"]["pkgs"] + self._global_pkgs
            }

            self._secondary_tool = None
            if "secondary" in _PKGS[self._name]:
                self._secondary_tool = {
                    "name": _PKGS[self._name]["secondary"]["name"],
                    "args": _PKGS[self._name]["secondary"]["args"],
                    "sudo": _PKGS[self._name]["secondary"]["sudo"],
                    "pkgs": _PKGS[self._name]["secondary"]["pkgs"]
                }

    def _check_existing_pkg(self, pkg):
        """Check whether or not a pkg has been already installed

        :pkg: String of the package to check
        :returns: TODO

        """
        pass

    def __create_cmd(self, pkgs_data):
        """Join all elements of the install command

        :pkgs_data: JSON data of the next packages to install

        :returns: TODO

        """
        install_cmd = []
        if pkgs_data["sudo"]:
            install_cmd.append("sudo")

        install_cmd.append(pkgs_data["name"])
        install_cmd.append(pkgs_data["args"])
        install_cmd += pkgs_data["pkgs"]

        return install_cmd

    def install_pkgs(self):
        """Install the available packages for the current OS

        :returns: TODO

        """
        status_message("Installings main tool packages")
        status_message("Using: {0}".format(self._main_tool["name"]))

        install_cmd = self.__create_cmd(self._main_tool)

        status_message("Command:\n{0}  ".format(" ".join(install_cmd)))

        call(install_cmd)

        status_message("Installings secondary tool packages")
        status_message("Using: {0}  ".format(self._secondary_tool["name"]))
        install_cmd = self.__create_cmd(self._secondary_tool)

        status_message("Command:\n{0}  ".format(" ".join(install_cmd)))

        call(install_cmd)
        pass


def __parse_arguments():
    """ Function to parse CLI args
    :returns: TODO

    """
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file", help="File with desire packages",
                        type=str)
    cli_args = parser.parse_args()

    return cli_args


def read_packages(filename):
    """Read the provided packages from json file

    :filename: TODO
    :returns: TODO

    """
    json_pkgs = None

    try:
        with open(filename, "r") as pkgs:
            json_pkgs = json.load(pkgs)
    except IOError as e:
        error_message("While loading the file {0}: {1}".format(filename, e))
    except ValueError as e:
        error_message("The file {0} doesn't exist {1}".format(filename, e))
    except Exception as e:
        error_message("{0}".format(e))

    return json_pkgs


def main():
    """Main funtion to setup current system
    :returns: TODO

    """
    cli_args = __parse_arguments()

    data = None
    if cli_args.file is not None:
        data = read_packages(cli_args.file)

    try:
        manager = PkgManager(data)
        manager.install_pkgs()
    except ValueError as e:
        error_message("Invalid OS value {0}".format(e))
    except Exception as e:
        error_message(e)


if __name__ == "__main__":
    main()
