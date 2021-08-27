#!/usr/bin/env python

from __future__ import print_function
from __future__ import division
from __future__ import unicode_literals
from __future__ import with_statement

import argparse
import logging
import os

# import sys
# import platform

from imagededup.methods import PHash
from imagededup.methods import AHash
from imagededup.methods import DHash
from imagededup.methods import WHash
from imagededup.methods import CNN


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

_version = "0.1.0"
_author = "Mike"
_mail = "mickiller.25@gmail.com"


def _parseArgs():
    """Parse CLI arguments
    :returns: argparse.ArgumentParser class instance

    """
    parser = argparse.ArgumentParser()

    home = os.environ["HOME"]

    parser.add_argument(
        "--version",
        dest="show_version",
        action="store_true",
        help="print script version and exit",
    )

    parser.add_argument(
        "-l",
        "--logging",
        dest="logging",
        default="INFO",
        type=str,
        help="Enable debug messages",
    )

    parser.add_argument(
        "-o",
        "--output",
        dest="output",
        default="duplicates.json",
        type=str,
        help="Output file",
    )

    parser.add_argument(
        "-d",
        "--image_dir",
        dest="dir",
        default=os.path.join(home, "Pictures"),
        type=str,
        help="Directory to inspect",
    )

    parser.add_argument(
        "-t",
        "--threshold",
        dest="threshold",
        default=12,
        type=int,
        help="Image duplicate threshold",
    )

    parser.add_argument("-s", "--score", dest="score", action="store_true", help="Enable scores")

    parser.add_argument(
        "-m",
        "--method",
        dest="method",
        choices=["phash", "ahash", "dhash", "whash", "cnn"],
        default="phash",
        help="Hash method",
    )

    return parser.parse_args()


def main():
    """Main function
    :returns: TODO

    """
    args = _parseArgs()

    if args.show_version:
        print(_version)
        return 0

    if args.logging:
        try:
            level = int(args.logging)
        except Exception:
            if args.logging.lower() == "debug":
                level = logging.DEBUG
            elif args.logging.lower() == "info":
                level = logging.INFO
            elif args.logging.lower() == "warn" or args.logging.lower() == "warning":
                level = logging.WARN
            elif args.logging.lower() == "error":
                level = logging.ERROR
            elif args.logging.lower() == "critical":
                level = logging.CRITICAL
            else:
                level = 0

    logging.basicConfig(level=level, format="[%(levelname)s] - %(message)s")

    outfile = args.output
    image_dir = args.dir
    threshold = args.threshold
    score = args.score

    logging.debug(f"Looking duplicates in {image_dir}")
    logging.debug(f"Using threshold {threshold}")
    logging.debug(f"Output file {outfile}")

    methods = {
        "phash": PHash,
        "ahash": AHash,
        "dhash": DHash,
        "whash": WHash,
        "cnn": CNN,
    }

    logging.debug(f"Using Hash method {args.method}")

    hasher = methods[args.method.lower()]()
    hasher.find_duplicates(
        image_dir=image_dir,
        max_distance_threshold=threshold,
        scores=score,
        outfile=outfile,
    )

    logging.info("Finished")

    return 0


if __name__ == "__main__":
    main()
