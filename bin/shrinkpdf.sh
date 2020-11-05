#!/bin/bash

# http://www.alfredklomp.com/programming/shrinkpdf
# Licensed under the 3-clause BSD license:
#
# Copyright (c) 2014-2019, Alfred Klomp
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# colors
# shellcheck disable=SC2034
black="\033[0;30m"
# shellcheck disable=SC2034
red="\033[0;31m"
# shellcheck disable=SC2034
green="\033[0;32m"
# shellcheck disable=SC2034
yellow="\033[0;33m"
# shellcheck disable=SC2034
blue="\033[0;34m"
# shellcheck disable=SC2034
purple="\033[0;35m"
# shellcheck disable=SC2034
cyan="\033[0;36m"
# shellcheck disable=SC2034
white="\033[0;37;1m"
# shellcheck disable=SC2034
orange="\033[0;91m"
# shellcheck disable=SC2034
normal="\033[0m"
# shellcheck disable=SC2034
reset_color="\033[39m"

NAME="$0"
NAME="${NAME##*/}"
LOG="${NAME%%.*}.log"
NOLOG=1
NOCOLOR=0

WARN_COUNT=0
ERR_COUNT=0

SCRIPT_PATH="$0"
SCRIPT_PATH="${SCRIPT_PATH%/*}"

trap '{ exit_append; }' EXIT

function warn_msg() {
    local warn_message="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$warn_message"
    else
        printf "[!] Warning:\t %s\n" "$warn_message"
    fi
    WARN_COUNT=$(( WARN_COUNT + 1 ))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$warn_message" >> "${LOG}"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$error_message" 1>&2
    else
        printf "[X] Error:\t %s\n" "$error_message" 1>&2
    fi
    ERR_COUNT=$(( ERR_COUNT + 1 ))
    if [[ $NOLOG -eq 0 ]]; then
        printf "[X] Error:\t\t %s\n" "$error_message" >> "${LOG}"
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s\n" "$status_message"
    else
        printf "[*] Info:\t %s\n" "$status_message"
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$status_message" >> "${LOG}"
    fi
    return 0
}

function verbose_msg() {
    local debug_message="$1"
    if [[ $_VERBOSE -eq 1 ]]; then
        if [[ $NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$debug_message"
        else
            printf "[+] Debug:\t %s\n" "$debug_message"
        fi
    fi
    if [[ $NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$debug_message" >> "${LOG}"
    fi
    return 0
}

function initlog() {
    if [[ $NOLOG -eq 0 ]]; then
        rm -f "${LOG}" 2>/dev/null
        if ! touch "${LOG}" &>/dev/null; then
            error_msg "Fail to init log file"
            NOLOG=1
            return 1
        fi
        if [[ -f "${SCRIPT_PATH}/shell/banner" ]]; then
            cat "${SCRIPT_PATH}/shell/banner" > "${LOG}"
        fi
        if ! is_osx; then
            LOG=$(readlink -e "${LOG}")
        fi
        verbose_msg "Using log at ${LOG}"
    fi
    return 0
}


function exit_append() {
    if [[ $NOLOG -eq 0 ]]; then
        if [[ $WARN_COUNT -gt 0 ]] || [[ $ERR_COUNT -gt 0 ]]; then
            printf "\n\n" >> "${LOG}"
        fi

        if [[ $WARN_COUNT -gt 0 ]]; then
            printf "[*] Warnings:\t%s\n" "$WARN_COUNT" >> "${LOG}"
        fi
        if [[ $ERR_COUNT -gt 0 ]]; then
            printf "[*] Errors:\t\t%s\n" "$ERR_COUNT" >> "${LOG}"
        fi
    fi
    return 0
}

#
# Modified by Vivek Gite to suit my needs
#
shrink() {

    status_msg "Shrinking PDF size"

    gs                                       \
        -q -dNOPAUSE -dBATCH -dSAFER         \
        -sDEVICE=pdfwrite                    \
        -dCompatibilityLevel=1.3             \
        -dPDFSETTINGS=/screen                \
        -dEmbedAllFonts=true                 \
        -dSubsetFonts=true                   \
        -dAutoRotatePages=/None              \
        -dColorImageDownsampleType=/Bicubic  \
        -dColorImageResolution="$3"          \
        -dGrayImageDownsampleType=/Bicubic   \
        -dGrayImageResolution= "$3"          \
        -dMonoImageDownsampleType=/Subsample \
        -dMonoImageResolution= "$3"          \
        -sOutputFile= "$2"                   \
        "$1"
}

check_smaller () {
    # If $1 and $2 are regular files, we can compare file sizes to
    # see if we succeeded in shrinking. If not, we copy $1 over $2:
    if [[ ! -f "$1" ]] || [[ ! -f "$2" ]]; then
        return 0;
    fi
    ISIZE=$(wc -c "$1" | cut -f1 -d\ )
    OSIZE=$(wc -c "$2" | cut -f1 -d\ )
    if [ "$ISIZE" -lt "$OSIZE" ]; then
        status_msg "Input smaller than output, doing straight copy" >&2
        cp "$1" "$2"
    fi
}

usage () {
    cat<<EOF
    Reduces PDF filesize by lossy recompressing with Ghostscript.
    Not guaranteed to succeed, but usually works.
      Usage: $NAME infile [outfile] [resolution_in_dpi]
EOF
}

initlog

IFILE="$1"

# Need an input file:
if [ -z "$IFILE" ]; then
    error_msg "Missing input file"
    usage
    exit 1
fi

# Output filename defaults to "-" (stdout) unless given:
if [ -n "$2" ]; then
    OFILE="$2"
else
    OFILE="-"
fi

# Output resolution defaults to 72 unless given:
if [ -n "$3" ]; then
    res="$3"
else
    res="90"
fi

verbose_msg "Using resolution: $res"

shrink "$IFILE" "$OFILE" "$res" || exit $?

check_smaller "$IFILE" "$OFILE"
